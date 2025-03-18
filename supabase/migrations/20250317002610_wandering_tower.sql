/*
  # Generate 2025 Tournament Bracket Games

  1. Purpose
    - Create initial Round of 64 games
    - Create placeholder games for later rounds
    - Set proper game numbers and dates
    - Maintain bracket structure

  2. Details
    - Round of 64: 32 games
    - Round of 32: 16 games
    - Sweet 16: 8 games
    - Elite 8: 4 games
    - Final Four: 2 games
    - Championship: 1 game
*/

DO $$
DECLARE
  v_season_id uuid;
  v_round_id uuid;
BEGIN
  -- Get the 2025 season ID
  SELECT id INTO v_season_id 
  FROM seasons 
  WHERE year = 2025;

  -- First create Round of 64 matchups
  SELECT id INTO v_round_id
  FROM rounds
  WHERE name = 'Round of 64';

  -- Insert Round of 64 games
  INSERT INTO games (
    season_id,
    round_id,
    team1_id,
    team2_id,
    game_number,
    game_date
  )
  SELECT 
    v_season_id,
    v_round_id,
    t1.id,
    t2.id,
    t1.overall_seed,
    NOW() + ((t1.overall_seed - 1) || ' hours')::interval
  FROM teams t1
  JOIN teams t2 ON t2.overall_seed = 65 - t1.overall_seed
  WHERE t1.season_id = v_season_id
    AND t2.season_id = v_season_id
    AND t1.overall_seed < t2.overall_seed;

  -- Create placeholder games for later rounds
  INSERT INTO games (
    season_id,
    round_id,
    game_number,
    game_date
  )
  SELECT 
    v_season_id,
    r.id,
    g.game_number,
    CASE r.name
      WHEN 'Round of 32' THEN NOW() + interval '3 days'
      WHEN 'Sweet 16' THEN NOW() + interval '5 days'
      WHEN 'Elite 8' THEN NOW() + interval '7 days'
      WHEN 'Final Four' THEN NOW() + interval '9 days'
      WHEN 'Championship' THEN NOW() + interval '11 days'
    END
  FROM rounds r
  CROSS JOIN LATERAL (
    SELECT generate_series(1, 
      CASE r.name
        WHEN 'Round of 32' THEN 16
        WHEN 'Sweet 16' THEN 8
        WHEN 'Elite 8' THEN 4
        WHEN 'Final Four' THEN 2
        WHEN 'Championship' THEN 1
      END
    ) as game_number
  ) g
  WHERE r.name IN ('Round of 32', 'Sweet 16', 'Elite 8', 'Final Four', 'Championship');

END $$;