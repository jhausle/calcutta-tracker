/*
  # Update Team Earnings View with Tax Calculation

  1. Changes
    - Add 25% tax calculation for purchases over $250
    - Update total investment to include tax
    - Use decimal values for purchase prices
    
  2. Details
    - Tax is 25% on amount over $250
    - Updates net profit calculation to account for tax
*/

-- Drop the existing view
DROP VIEW IF EXISTS team_earnings;

-- Recreate the view with tax calculation
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
),
owner_totals AS (
  SELECT 
    t.owner_id,
    t.season_id,
    SUM(t.purchase_price) as total_purchase_price
  FROM teams t
  WHERE t.owner_id IS NOT NULL
  GROUP BY t.owner_id, t.season_id
),
owner_tax_calc AS (
  SELECT
    owner_id,
    season_id,
    total_purchase_price,
    CASE 
      WHEN total_purchase_price > 250 THEN
        (total_purchase_price - 250) * 0.25
      ELSE 0
    END as tax_amount
  FROM owner_totals
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
  otc.total_purchase_price as owner_total_purchase,
  otc.tax_amount as owner_tax,
  otc.total_purchase_price + otc.tax_amount as owner_total_with_tax,
  COALESCE(tec.total_earnings, 0) as total_earnings,
  COALESCE(tec.total_earnings, 0) - (t.purchase_price + 
    CASE 
      WHEN otc.total_purchase_price > 250 
      THEN (t.purchase_price / otc.total_purchase_price) * otc.tax_amount
      ELSE 0 
    END
  ) as net_profit
FROM teams t
LEFT JOIN owners o ON o.id = t.owner_id
JOIN seasons s ON s.id = t.season_id
LEFT JOIN team_earnings_calc tec ON tec.team_id = t.id AND tec.season_id = t.season_id
LEFT JOIN owner_tax_calc otc ON otc.owner_id = t.owner_id AND otc.season_id = t.season_id;