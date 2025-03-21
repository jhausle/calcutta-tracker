DROP FUNCTION IF EXISTS advance_to_next_round;

CREATE OR REPLACE FUNCTION advance_to_next_round(
  game_id UUID,
  winner_team_id UUID,
  team1_score INTEGER DEFAULT NULL,
  team2_score INTEGER DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
  debug_info jsonb;
BEGIN
  -- First, verify the parameters
  debug_info := jsonb_build_object(
    'params_received', jsonb_build_object(
      'game_id', game_id,
      'winner_team_id', winner_team_id,
      'team1_score', team1_score,
      'team2_score', team2_score
    )
  );

  -- Check if game exists
  debug_info := debug_info || jsonb_build_object(
    'game_exists', EXISTS (
      SELECT 1 FROM games WHERE id = game_id
    )
  );

  -- Check if winner team exists
  debug_info := debug_info || jsonb_build_object(
    'team_exists', EXISTS (
      SELECT 1 FROM teams WHERE id = winner_team_id
    )
  );

  -- Try to update the game
  UPDATE games 
  SET winner_id = winner_team_id,
      team1_score = COALESCE($3, games.team1_score),
      team2_score = COALESCE($4, games.team2_score)
  WHERE id = game_id;

  -- Check if update worked
  debug_info := debug_info || jsonb_build_object(
    'update_success', EXISTS (
      SELECT 1 FROM games 
      WHERE id = game_id AND winner_id = winner_team_id
    )
  );

  RETURN debug_info;
END;
$$ LANGUAGE plpgsql; 