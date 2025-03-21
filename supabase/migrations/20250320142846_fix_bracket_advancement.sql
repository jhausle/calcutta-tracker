-- Drop the existing function
DROP FUNCTION IF EXISTS advance_to_next_round;

-- Create the updated function with fixed bracket advancement
CREATE OR REPLACE FUNCTION advance_to_next_round(
  game_id UUID,
  winner_team_id UUID,
  team1_score INTEGER DEFAULT NULL,
  team2_score INTEGER DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  next_game_id UUID;
  current_game_number INTEGER;
  next_game_number INTEGER;
  current_round INTEGER;
  winner_region TEXT;
  should_be_team1 BOOLEAN;
BEGIN
  -- Update the current game with the winner and scores
  UPDATE games 
  SET winner_id = winner_team_id,
      team1_score = COALESCE(team1_score, games.team1_score),
      team2_score = COALESCE(team2_score, games.team2_score)
  WHERE id = game_id;

  -- Get the current game info
  SELECT 
    g.game_number,
    r.round_number,
    t.region
  INTO 
    current_game_number,
    current_round,
    winner_region
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  JOIN teams t ON t.id = winner_team_id
  WHERE g.id = game_id;

  -- Calculate next game number and position
  CASE current_round
    WHEN 1 THEN
      -- First round: Game 1 plays Game 32, Game 2 plays Game 31, etc.
      IF current_game_number <= 16 THEN
        next_game_number := current_game_number;
        should_be_team1 := TRUE;
      ELSE
        next_game_number := 33 - current_game_number;
        should_be_team1 := FALSE;
      END IF;
    WHEN 2 THEN
      -- Second round: Game 1 plays Game 8, Game 2 plays Game 7, etc.
      IF current_game_number <= 8 THEN
        next_game_number := (current_game_number + 1) / 2;
        should_be_team1 := TRUE;
      ELSE
        next_game_number := 9 - (current_game_number + 1) / 2;
        should_be_team1 := FALSE;
      END IF;
    WHEN 3 THEN
      -- Sweet 16: Game 1 plays Game 4, Game 2 plays Game 3
      IF current_game_number <= 4 THEN
        next_game_number := (current_game_number + 1) / 2;
        should_be_team1 := TRUE;
      ELSE
        next_game_number := 5 - (current_game_number + 1) / 2;
        should_be_team1 := FALSE;
      END IF;
    WHEN 4 THEN
      -- Elite 8: Game 1 plays Game 2
      next_game_number := 1;
      should_be_team1 := (current_game_number = 1);
    WHEN 5 THEN
      -- Final Four: Winners advance to championship
      next_game_number := 1;
      should_be_team1 := (current_game_number = 1);
  END CASE;

  -- Find the next game
  SELECT g.id
  INTO next_game_id
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  WHERE r.round_number = current_round + 1
    AND g.game_number = next_game_number
    AND (
      (current_round = 1 AND g.region = winner_region) OR
      (current_round > 1)
    );

  -- Update the next game with the winner in the correct position
  IF next_game_id IS NOT NULL THEN
    IF should_be_team1 THEN
      UPDATE games SET team1_id = winner_team_id WHERE id = next_game_id;
    ELSE
      UPDATE games SET team2_id = winner_team_id WHERE id = next_game_id;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql; 