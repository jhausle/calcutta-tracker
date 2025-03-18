/*
  # Set up tournament rounds and games

  1. Purpose
    - Add unique constraint to rounds table
    - Create all tournament rounds with correct payout percentages
    - Set up game progression mapping
    - Initialize placeholder games for each round
    
  2. Details
    - Creates 6 rounds with increasing payout percentages
    - Sets up game progression mapping
    - Creates placeholder games for each round
    - Preserves existing Round of 64 games

  3. Payout Structure
    - Round of 64: 5% of prize pool
    - Round of 32: 10% of prize pool
    - Sweet 16: 15% of prize pool
    - Elite Eight: 20% of prize pool
    - Final Four: 25% of prize pool
    - Championship: 25% of prize pool
*/

-- First, add unique constraint to rounds table
ALTER TABLE rounds ADD CONSTRAINT rounds_name_key UNIQUE (name);

DO $$
DECLARE
  v_season_id uuid;
  v_round_id uuid;
  v_round record;
  v_game_number int;
  v_rounds jsonb;
BEGIN
  -- Get the current season ID
  SELECT id INTO v_season_id FROM seasons WHERE year = 2024 LIMIT 1;
  
  -- Define rounds structure with payout percentages
  v_rounds := jsonb_build_array(
    jsonb_build_object('name', 'Round of 64', 'num_matches', 32, 'payout', 0.05),
    jsonb_build_object('name', 'Round of 32', 'num_matches', 16, 'payout', 0.10),
    jsonb_build_object('name', 'Sweet 16', 'num_matches', 8, 'payout', 0.15),
    jsonb_build_object('name', 'Elite Eight', 'num_matches', 4, 'payout', 0.20),
    jsonb_build_object('name', 'Final Four', 'num_matches', 2, 'payout', 0.25),
    jsonb_build_object('name', 'Championship', 'num_matches', 1, 'payout', 0.25)
  );

  -- First, ensure rounds exist and update round_number
  FOR v_round IN 
    SELECT value->>'name' as name, 
           (value->>'num_matches')::int as num_matches,
           (value->>'payout')::numeric as payout_percentage,
           ordinality as round_number
    FROM jsonb_array_elements(v_rounds) WITH ORDINALITY
  LOOP
    -- Create or update round
    INSERT INTO rounds (name, round_number, payout_percentage)
    VALUES (v_round.name, v_round.round_number, v_round.payout_percentage)
    ON CONFLICT (name) 
    DO UPDATE SET 
      round_number = EXCLUDED.round_number,
      payout_percentage = EXCLUDED.payout_percentage
    RETURNING id INTO v_round_id;

    -- Skip Round of 64 as it already has games
    IF v_round.name != 'Round of 64' THEN
      -- Create placeholder games for this round
      FOR v_game_number IN 1..v_round.num_matches LOOP
        -- Only insert if game doesn't exist
        INSERT INTO games (
          round_id,
          season_id,
          game_number
        )
        SELECT 
          v_round_id,
          v_season_id,
          v_game_number
        WHERE NOT EXISTS (
          SELECT 1 
          FROM games 
          WHERE round_id = v_round_id 
          AND season_id = v_season_id 
          AND game_number = v_game_number
        );
      END LOOP;
    END IF;
  END LOOP;

  -- Set up game progression mapping
  INSERT INTO game_progression (
    round_name,
    match_number,
    next_round_name,
    next_match_number,
    team_position
  )
  SELECT 
    r1.name as round_name,
    g1.game_number as match_number,
    r2.name as next_round_name,
    ceil(g1.game_number::float / 2) as next_match_number,
    CASE 
      WHEN g1.game_number % 2 = 1 THEN 1
      ELSE 2
    END as team_position
  FROM games g1
  JOIN rounds r1 ON g1.round_id = r1.id
  JOIN rounds r2 ON r1.round_number + 1 = r2.round_number
  WHERE g1.season_id = v_season_id
  AND NOT EXISTS (
    SELECT 1 
    FROM game_progression gp 
    WHERE gp.round_name = r1.name 
    AND gp.match_number = g1.game_number
  )
  ORDER BY r1.round_number, g1.game_number;

END $$;