/*
  # Game Progression System

  1. Changes
    - Drops existing procedure to allow parameter name changes
    - Recreates advance_to_next_round procedure with updated parameters
    - Handles tournament progression logic
    - Manages game creation and team placement
    - Grants execute permission to authenticated users
*/

-- Drop the existing procedure first
DROP PROCEDURE IF EXISTS advance_to_next_round(UUID, UUID);

-- Procedure to advance winners to the next round
CREATE OR REPLACE PROCEDURE advance_to_next_round(
  game_id UUID,
  winner_team_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_round_number INTEGER;
  next_round_id UUID;
  next_game_number INTEGER;
  team_position INTEGER;
  current_game_number INTEGER;
  current_season_id UUID;
BEGIN
  -- Get the current game's round number, game number, and season
  SELECT 
    r.round_number,
    g.game_number,
    g.season_id
  INTO 
    current_round_number,
    current_game_number,
    current_season_id
  FROM games g
  JOIN rounds r ON r.id = g.round_id
  WHERE g.id = game_id;

  -- Get the next round's ID
  SELECT id 
  INTO next_round_id
  FROM rounds
  WHERE round_number = current_round_number + 1;

  -- If there's no next round, we're done
  IF next_round_id IS NULL THEN
    RETURN;
  END IF;

  -- Calculate the next game number and team position
  next_game_number := (current_game_number + 1) / 2;
  team_position := CASE 
    WHEN current_game_number % 2 = 1 THEN 1 
    ELSE 2 
  END;

  -- Check if the next game already exists
  IF EXISTS (
    SELECT 1 
    FROM games 
    WHERE round_id = next_round_id 
    AND game_number = next_game_number
    AND season_id = current_season_id
  ) THEN
    -- Update existing game with the winner in the correct position
    IF team_position = 1 THEN
      UPDATE games 
      SET team1_id = winner_team_id
      WHERE round_id = next_round_id 
      AND game_number = next_game_number
      AND season_id = current_season_id;
    ELSE
      UPDATE games 
      SET team2_id = winner_team_id
      WHERE round_id = next_round_id 
      AND game_number = next_game_number
      AND season_id = current_season_id;
    END IF;
  ELSE
    -- Create new game with the winner in the correct position
    INSERT INTO games (
      round_id,
      season_id,
      game_number,
      team1_id,
      team2_id
    ) VALUES (
      next_round_id,
      current_season_id,
      next_game_number,
      CASE WHEN team_position = 1 THEN winner_team_id ELSE NULL END,
      CASE WHEN team_position = 2 THEN winner_team_id ELSE NULL END
    );
  END IF;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON PROCEDURE advance_to_next_round(UUID, UUID) TO authenticated;