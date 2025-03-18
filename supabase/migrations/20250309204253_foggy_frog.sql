/*
  # Add game number to games table

  1. Changes
    - Add game_number column to games table
    - Set game_number for round 1 games based on higher seed
    - Add constraint to ensure game_number is positive

  2. Notes
    - For round 1, game_number matches the lower seed number
      (e.g., game between seed 1 and 16 is game 1)
    - Future rounds will use different numbering logic
*/

-- Add game_number column
ALTER TABLE games 
ADD COLUMN game_number integer;

-- Add constraint to ensure positive game numbers
ALTER TABLE games
ADD CONSTRAINT valid_game_number CHECK (game_number > 0);

-- Update existing round 1 games with game numbers based on higher seed
DO $$
DECLARE
  v_round_id uuid;
BEGIN
  -- Get the Round of 64 ID
  SELECT id INTO v_round_id
  FROM rounds
  WHERE round_number = 1;

  -- Update game_number for round 1 games
  UPDATE games g
  SET game_number = (
    SELECT LEAST(t1.region_seed, t2.region_seed)
    FROM teams t1, teams t2
    WHERE t1.id = g.team1_id AND t2.id = g.team2_id
  )
  WHERE g.round_id = v_round_id;
END $$;