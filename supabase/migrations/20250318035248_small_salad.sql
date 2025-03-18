/*
  # Fix Purchase Price Type and Values

  1. Changes
    - Drop team_earnings view temporarily
    - Change purchase_price column type from integer to numeric
    - Divide all existing prices by 100 to get correct decimal values
    - Recreate team_earnings view
    - Update season prize pool to match new total

  2. Details
    - Uses numeric type to handle decimal places
    - Maintains data integrity with transaction
    - Updates all 2025 season teams
*/

-- Drop the view that depends on the column
DROP VIEW IF EXISTS team_earnings;

-- Change the column type to numeric
ALTER TABLE teams
ALTER COLUMN purchase_price TYPE numeric;

-- Update all team purchase prices for 2025 season
UPDATE teams 
SET purchase_price = purchase_price / 100
WHERE season_id = (
  SELECT id 
  FROM seasons 
  WHERE year = 2025
);

-- Update season prize pool to match new total
UPDATE seasons 
SET prize_pool = (
  SELECT SUM(purchase_price)
  FROM teams
  WHERE season_id = seasons.id
)
WHERE year = 2025;

-- Recreate the team_earnings view
CREATE OR REPLACE VIEW team_earnings AS
WITH game_results AS (
  SELECT
    CASE 
      WHEN g.winner_id = g.team1_id THEN g.team1_id
      WHEN g.winner_id = g.team2_id THEN g.team2_id
      ELSE NULL
    END as winning_team_id,
    g.season_id,
    r.payout_percentage,
    s.prize_pool
  FROM games g
  JOIN rounds r ON r.id = g.round_id
  JOIN seasons s ON s.id = g.season_id
  WHERE g.winner_id IS NOT NULL
),
team_earnings_calc AS (
  SELECT
    gr.winning_team_id as team_id,
    gr.season_id,
    SUM(gr.prize_pool * gr.payout_percentage) as total_earnings
  FROM game_results gr
  GROUP BY gr.winning_team_id, gr.season_id
)
SELECT
  t.id as team_id,
  t.season_id,
  s.year as season_year,
  s.name as season_name,
  s.prize_pool,
  t.college,
  t.region,
  t.overall_seed,
  t.region_seed,
  t.purchase_price,
  o.name as owner_name,
  o.email as owner_email,
  COALESCE(tec.total_earnings, 0) as total_earnings,
  COALESCE(tec.total_earnings, 0) - t.purchase_price as net_profit
FROM teams t
LEFT JOIN owners o ON o.id = t.owner_id
JOIN seasons s ON s.id = t.season_id
LEFT JOIN team_earnings_calc tec ON tec.team_id = t.id AND tec.season_id = t.season_id;