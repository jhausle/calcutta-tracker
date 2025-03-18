/*
  # Generate Tournament Games

  1. Purpose
    - Creates empty game slots for each tournament round
    - Generates the following games:
      - Round of 32: 16 games
      - Sweet 16: 8 games
      - Elite 8: 4 games
      - Final Four: 2 games
      - Championship: 1 game
    
  2. Details
    - Uses current season (2024)
    - Sets future game dates for each round
    - Assigns sequential game numbers within each round
*/

WITH RECURSIVE round_games AS (
  SELECT 
    r.id as round_id,
    r.name as round_name,
    CASE r.name
      WHEN 'Round of 32' THEN 16
      WHEN 'Sweet 16' THEN 8
      WHEN 'Elite 8' THEN 4
      WHEN 'Final Four' THEN 2
      WHEN 'Championship' THEN 1
    END as num_games,
    CASE r.name
      WHEN 'Round of 32' THEN NOW() + interval '3 days'
      WHEN 'Sweet 16' THEN NOW() + interval '5 days'
      WHEN 'Elite 8' THEN NOW() + interval '7 days'
      WHEN 'Final Four' THEN NOW() + interval '9 days'
      WHEN 'Championship' THEN NOW() + interval '11 days'
    END as game_date
  FROM rounds r
  WHERE r.name IN ('Round of 32', 'Sweet 16', 'Elite 8', 'Final Four', 'Championship')
),
season AS (
  SELECT id 
  FROM seasons 
  WHERE year = 2024
  LIMIT 1
),
game_numbers AS (
  SELECT 
    round_id,
    round_name,
    game_date,
    generate_series(1, num_games) as game_number
  FROM round_games
)
INSERT INTO games (
  season_id,
  round_id,
  game_number,
  game_date
)
SELECT 
  s.id as season_id,
  g.round_id,
  g.game_number,
  g.game_date
FROM season s
CROSS JOIN game_numbers g;