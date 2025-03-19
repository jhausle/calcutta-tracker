-- Add parameters for scores
CREATE OR REPLACE FUNCTION advance_to_next_round(
  game_id UUID,
  winner_team_id UUID,
  team1_score INTEGER DEFAULT NULL,
  team2_score INTEGER DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  next_game_id UUID;
  next_game_team1_id UUID;
  next_game_team2_id UUID;
  current_round INTEGER;
  winner_region TEXT;
BEGIN
  -- Update the current game with the winner and scores
  UPDATE games 
  SET winner_id = winner_team_id,
      team1_score = COALESCE(team1_score, games.team1_score),
      team2_score = COALESCE(team2_score, games.team2_score)
  WHERE id = game_id;

  -- Get the current round number and winner's region
  SELECT r.round_number, t.region
  INTO current_round, winner_region
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  JOIN teams t ON t.id = winner_team_id
  WHERE g.id = game_id;

  -- Find the next game where this winner should advance to
  SELECT 
    g.id,
    g.team1_id,
    g.team2_id
  INTO 
    next_game_id,
    next_game_team1_id,
    next_game_team2_id
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  WHERE r.round_number = current_round + 1
    AND (
      (current_round = 1 AND g.region = winner_region) OR
      (current_round > 1)
    )
    AND (g.team1_id IS NULL OR g.team2_id IS NULL);

  -- Update the next game with the winner in the appropriate slot
  IF next_game_id IS NOT NULL THEN
    IF next_game_team1_id IS NULL THEN
      UPDATE games SET team1_id = winner_team_id WHERE id = next_game_id;
    ELSE
      UPDATE games SET team2_id = winner_team_id WHERE id = next_game_id;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql; 