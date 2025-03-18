/*
  # Update game numbers based on overall seed

  1. Changes
    - Update game_number for round 1 games based on overall seed
    - Game numbers are based on overall seed (1-64)
    - Game between overall seeds 1 and 64 is game 1
    - Game between overall seeds 2 and 63 is game 2, etc.

  2. Notes
    - Column and constraint already exist
    - Only updating the game numbers for round 1
*/

-- Update existing round 1 games with game numbers based on overall seed
DO $$
DECLARE
  v_round_id uuid;
BEGIN
  -- Get the Round of 64 ID
  SELECT id INTO v_round_id
  FROM rounds
  WHERE round_number = 1;

  -- Update game_number for round 1 games based on overall seed
  UPDATE games g
  SET game_number = (
    SELECT LEAST(t1.overall_seed, t2.overall_seed)
    FROM teams t1, teams t2
    WHERE t1.id = g.team1_id AND t2.id = g.team2_id
  )
  WHERE g.round_id = v_round_id;
END $$;