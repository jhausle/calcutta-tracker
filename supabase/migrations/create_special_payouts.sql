-- Add seed column to teams table if it doesn't exist
ALTER TABLE teams ADD COLUMN IF NOT EXISTS seed INTEGER;

-- Create a view for tracking the lowest seed to reach Sweet 16
CREATE OR REPLACE VIEW lowest_seed_sweet_16 AS
SELECT 
  t.id,
  t.college,
  t.region_seed as seed,
  s.year
FROM teams t
JOIN games g1 ON (t.id = g1.team1_id OR t.id = g1.team2_id)
JOIN rounds r1 ON g1.round_id = r1.id
JOIN games g2 ON (t.id = g2.winner_id)
JOIN rounds r2 ON g2.round_id = r2.id
JOIN games g3 ON (t.id = g3.winner_id)
JOIN rounds r3 ON g3.round_id = r3.id
JOIN seasons s ON t.season_id = s.id
WHERE r1.round_number = 1 
  AND r2.round_number = 2
  AND r3.round_number = 3
ORDER BY t.region_seed DESC
LIMIT 1;

-- Create a view for highest scoring round 1 loser
CREATE OR REPLACE VIEW highest_scoring_r1_loser AS
SELECT 
  t.id,
  t.college,
  t.region_seed as seed,
  CASE 
    WHEN t.id = g.team1_id THEN g.team1_score
    ELSE g.team2_score
  END as team_score,
  s.year
FROM teams t
JOIN games g ON (t.id = g.team1_id OR t.id = g.team2_id)
JOIN rounds r ON g.round_id = r.id
JOIN seasons s ON t.season_id = s.id
WHERE r.round_number = 1 
  AND t.id != g.winner_id
  AND g.team1_score IS NOT NULL
ORDER BY team_score DESC
LIMIT 1; 