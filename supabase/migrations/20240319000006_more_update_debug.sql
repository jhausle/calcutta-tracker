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
  game_info record;
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

  -- Get current game state
  SELECT g.*, t1.college as team1_name, t2.college as team2_name
  INTO game_info
  FROM games g
  LEFT JOIN teams t1 ON g.team1_id = t1.id
  LEFT JOIN teams t2 ON g.team2_id = t2.id
  WHERE g.id = game_id;

  -- Add game state to debug info
  debug_info := debug_info || jsonb_build_object(
    'current_game_state', jsonb_build_object(
      'team1_id', game_info.team1_id,
      'team2_id', game_info.team2_id,
      'team1_name', game_info.team1_name,
      'team2_name', game_info.team2_name,
      'current_winner_id', game_info.winner_id,
      'team1_score', game_info.team1_score,
      'team2_score', game_info.team2_score
    )
  );

  -- Verify winner is one of the teams
  debug_info := debug_info || jsonb_build_object(
    'winner_is_team1', winner_team_id = game_info.team1_id,
    'winner_is_team2', winner_team_id = game_info.team2_id,
    'winner_is_valid', (winner_team_id = game_info.team1_id OR winner_team_id = game_info.team2_id)
  );

  -- Try to update the game
  UPDATE games 
  SET winner_id = winner_team_id,
      team1_score = COALESCE($3, games.team1_score),
      team2_score = COALESCE($4, games.team2_score)
  WHERE id = game_id
  AND (team1_id = winner_team_id OR team2_id = winner_team_id);  -- Only update if winner is one of the teams

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