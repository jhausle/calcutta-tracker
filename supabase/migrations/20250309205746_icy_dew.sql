/*
  # Add placeholder games and advancement function

  1. Changes
    - Add round_number to rounds table
    - Add stored procedures for game generation and advancement
    - Add game progression handling

  2. Notes
    - Placeholder games are created with NULL team IDs
    - Games are linked via game_number for progression
    - advance_to_next_round procedure handles winner advancement
*/

-- Add round_number to rounds if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rounds' AND column_name = 'round_number'
  ) THEN
    ALTER TABLE rounds ADD COLUMN round_number integer;
    
    -- Set round numbers for existing rounds
    UPDATE rounds SET round_number = CASE
      WHEN name = 'Round of 64' THEN 1
      WHEN name = 'Round of 32' THEN 2
      WHEN name = 'Sweet 16' THEN 3
      WHEN name = 'Elite Eight' THEN 4
      WHEN name = 'Final Four' THEN 5
      WHEN name = 'Championship' THEN 6
    END;
    
    -- Make round_number NOT NULL after setting values
    ALTER TABLE rounds ALTER COLUMN round_number SET NOT NULL;
  END IF;
END $$;

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS generate_round1_games(uuid);
DROP PROCEDURE IF EXISTS advance_to_next_round(uuid, uuid);

-- Create procedure to generate placeholder games for all rounds
CREATE OR REPLACE PROCEDURE generate_round1_games(season_id uuid)
LANGUAGE plpgsql
AS $$
DECLARE
  v_round_id uuid;
  v_team1 record;
  v_team2 record;
  v_game_number integer;
BEGIN
  -- Get Round of 64 ID
  SELECT id INTO v_round_id FROM rounds WHERE round_number = 1;
  
  -- Create games for each seed pairing
  FOR v_game_number IN 1..32 LOOP
    -- Get teams based on overall seed
    SELECT id, college INTO v_team1
    FROM teams 
    WHERE season_id = $1 AND overall_seed = v_game_number;
    
    SELECT id, college INTO v_team2
    FROM teams 
    WHERE season_id = $1 AND overall_seed = (65 - v_game_number);
    
    -- Insert the game
    INSERT INTO games (
      season_id,
      round_id,
      team1_id,
      team2_id,
      game_number
    ) VALUES (
      $1,
      v_round_id,
      v_team1.id,
      v_team2.id,
      v_game_number
    );
  END LOOP;
  
  -- Create placeholder games for later rounds
  FOR i IN 2..6 LOOP
    INSERT INTO games (
      season_id,
      round_id,
      game_number
    )
    SELECT 
      season_id,
      r.id,
      gp.next_match_number
    FROM game_progression gp
    JOIN rounds r ON r.round_number = i
    WHERE gp.next_round_name = r.name
    GROUP BY season_id, r.id, gp.next_match_number;
  END LOOP;
END;
$$;

-- Create procedure to advance winners to next round
CREATE OR REPLACE PROCEDURE advance_to_next_round(game_id uuid, winner_id uuid)
LANGUAGE plpgsql
AS $$
DECLARE
  v_game record;
  v_progression record;
  v_next_game_id uuid;
BEGIN
  -- Get current game and round info
  SELECT g.*, r.name as round_name, r.round_number
  INTO v_game
  FROM games g
  JOIN rounds r ON r.id = g.round_id
  WHERE g.id = game_id;
  
  -- Get progression info
  SELECT *
  INTO v_progression
  FROM game_progression
  WHERE round_name = v_game.round_name
  AND match_number = v_game.game_number;
  
  -- If there's a next round, update the next game
  IF v_progression.next_round_name IS NOT NULL THEN
    -- Find the next game
    SELECT id 
    INTO v_next_game_id
    FROM games g
    JOIN rounds r ON r.id = g.round_id
    WHERE r.name = v_progression.next_round_name
    AND g.game_number = v_progression.next_match_number
    AND g.season_id = v_game.season_id;
    
    -- Update the appropriate team slot in the next game
    IF v_progression.team_position = 1 THEN
      UPDATE games 
      SET team1_id = winner_id
      WHERE id = v_next_game_id;
    ELSE
      UPDATE games 
      SET team2_id = winner_id
      WHERE id = v_next_game_id;
    END IF;
  END IF;
  
  -- Update current game's winner
  UPDATE games
  SET winner_id = winner_id
  WHERE id = game_id;
  
  -- Insert or update team result
  INSERT INTO team_results (
    team_id,
    round_id,
    season_id,
    won
  ) VALUES (
    winner_id,
    v_game.round_id,
    v_game.season_id,
    true
  )
  ON CONFLICT (team_id, round_id, season_id)
  DO UPDATE SET won = true;
  
  -- Insert or update losing team result
  INSERT INTO team_results (
    team_id,
    round_id,
    season_id,
    won
  ) VALUES (
    CASE 
      WHEN v_game.team1_id = winner_id THEN v_game.team2_id
      ELSE v_game.team1_id
    END,
    v_game.round_id,
    v_game.season_id,
    false
  )
  ON CONFLICT (team_id, round_id, season_id)
  DO UPDATE SET won = false;
END;
$$;