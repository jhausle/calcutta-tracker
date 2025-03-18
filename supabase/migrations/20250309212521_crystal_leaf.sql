/*
  # Update Round 1 Game Generation

  1. Changes
    - Drop existing procedure
    - Create new function for generating Round 1 games
    - Uses correct seeding pattern for 64-team tournament
    - Games are numbered 1-32 for proper ordering

  2. Technical Details
    - Uses temporary table for seed matchups
    - Ensures proper game numbering
    - Maintains data integrity with error handling
*/

-- Drop the existing procedure
DROP PROCEDURE IF EXISTS generate_round1_games;

-- Create the new function
CREATE OR REPLACE FUNCTION generate_round1_games(p_season_id UUID)
RETURNS void AS $$
DECLARE
  v_round_id UUID;
  v_team1_id UUID;
  v_team2_id UUID;
  v_matchup RECORD;
BEGIN
  -- Get the Round of 64 ID
  SELECT id INTO v_round_id
  FROM rounds
  WHERE name = 'Round of 64';

  IF v_round_id IS NULL THEN
    RAISE EXCEPTION 'Round of 64 not found';
  END IF;

  -- Clear existing games for this round and season
  DELETE FROM games
  WHERE season_id = p_season_id AND round_id = v_round_id;

  -- Create temporary table for matchups
  CREATE TEMPORARY TABLE temp_matchups (
    game_number INTEGER,
    seed1 INTEGER,
    seed2 INTEGER
  );

  -- Insert matchup data
  INSERT INTO temp_matchups (game_number, seed1, seed2) VALUES
    (1, 1, 64), (2, 32, 33), (3, 16, 49), (4, 17, 48),
    (5, 8, 57), (6, 25, 40), (7, 9, 56), (8, 24, 41),
    (9, 4, 61), (10, 29, 36), (11, 13, 52), (12, 20, 45),
    (13, 5, 60), (14, 28, 37), (15, 12, 53), (16, 21, 44),
    (17, 2, 63), (18, 31, 34), (19, 15, 50), (20, 18, 47),
    (21, 7, 58), (22, 26, 39), (23, 10, 55), (24, 23, 42),
    (25, 3, 62), (26, 30, 35), (27, 14, 51), (28, 19, 46),
    (29, 6, 59), (30, 27, 38), (31, 11, 54), (32, 22, 43);

  -- Create games based on seed matchups
  FOR v_matchup IN SELECT * FROM temp_matchups ORDER BY game_number
  LOOP
    -- Get team IDs for the seeds
    SELECT id INTO v_team1_id
    FROM teams
    WHERE season_id = p_season_id AND overall_seed = v_matchup.seed1;

    SELECT id INTO v_team2_id
    FROM teams
    WHERE season_id = p_season_id AND overall_seed = v_matchup.seed2;

    IF v_team1_id IS NULL OR v_team2_id IS NULL THEN
      RAISE WARNING 'Missing teams for game %, seeds % and %',
        v_matchup.game_number, v_matchup.seed1, v_matchup.seed2;
      CONTINUE;
    END IF;

    -- Insert the game
    INSERT INTO games (
      season_id,
      round_id,
      team1_id,
      team2_id,
      game_number,
      game_date
    ) VALUES (
      p_season_id,
      v_round_id,
      v_team1_id,
      v_team2_id,
      v_matchup.game_number,
      NOW() + interval '1 day'
    );
  END LOOP;

  -- Clean up
  DROP TABLE temp_matchups;
END;
$$ LANGUAGE plpgsql;