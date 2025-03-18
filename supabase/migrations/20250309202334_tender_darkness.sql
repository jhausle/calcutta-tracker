/*
  # Update team earnings view

  1. Changes
    - Modify team_earnings view to calculate earnings from game wins
    - Link earnings calculation to actual game results
    - Calculate total earnings and net profit per team

  2. Details
    - Uses games table to determine wins
    - Calculates earnings based on round payouts
    - Shows team and owner information
    - Computes net profit (earnings minus purchase price)
*/

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