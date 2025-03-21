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
  update_result text;
  error_info text;
BEGIN
  -- [Previous logging code remains the same...]

  -- Add team matching debug info
  debug_info := debug_info || jsonb_build_object(
    'team_matching', jsonb_build_object(
      'winner_id', winner_team_id,
      'team1_match', game_info.team1_id = winner_team_id,
      'team2_match', game_info.team2_id = winner_team_id,
      'team1_id', game_info.team1_id,
      'team2_id', game_info.team2_id
    )
  );

  -- Try the update with explicit transaction
  UPDATE games AS g
  SET winner_id = winner_team_id,
      team1_score = COALESCE($3, g.team1_score),
      team2_score = COALESCE($4, g.team2_score)
  WHERE g.id = game_id
  AND (g.team1_id = winner_team_id OR g.team2_id = winner_team_id);
  
  GET DIAGNOSTICS update_result = ROW_COUNT;
  
  -- [Rest of the function remains the same...]

END;
$$ LANGUAGE plpgsql; 