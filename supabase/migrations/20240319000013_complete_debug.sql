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
  -- Log the function call
  INSERT INTO function_logs (function_name, params)
  VALUES (
    'advance_to_next_round',
    jsonb_build_object(
      'game_id', game_id,
      'winner_team_id', winner_team_id,
      'team1_score', team1_score,
      'team2_score', team2_score
    )
  );

  -- Get current game state with more details
  SELECT 
    g.*,  -- Get all game fields
    t1.college as team1_name,
    t2.college as team2_name,
    r.round_number
  INTO game_info
  FROM games g
  LEFT JOIN teams t1 ON g.team1_id = t1.id
  LEFT JOIN teams t2 ON g.team2_id = t2.id
  LEFT JOIN rounds r ON g.round_id = r.id
  WHERE g.id = game_id;

  -- Add detailed game state and team matching to debug info
  debug_info := jsonb_build_object(
    'current_game_state', jsonb_build_object(
      'team1_id', game_info.team1_id,
      'team2_id', game_info.team2_id,
      'team1_name', game_info.team1_name,
      'team2_name', game_info.team2_name,
      'current_winner_id', game_info.winner_id,
      'current_team1_score', game_info.team1_score,
      'current_team2_score', game_info.team2_score,
      'game_number', game_info.game_number,
      'round_number', game_info.round_number,
      'season_id', game_info.season_id
    ),
    'team_matching', jsonb_build_object(
      'winner_id', winner_team_id,
      'team1_match', game_info.team1_id = winner_team_id,
      'team2_match', game_info.team2_id = winner_team_id,
      'team1_id', game_info.team1_id,
      'team2_id', game_info.team2_id
    )
  );

  -- Try to update the game with detailed error handling
  BEGIN
    -- First try a SELECT to verify the row is accessible
    PERFORM 1 FROM games WHERE id = game_id;
    
    IF NOT FOUND THEN
      error_info := 'Game not found in pre-update check';
      RAISE EXCEPTION 'Game not found';
    END IF;

    -- Try the update
    UPDATE games AS g
    SET winner_id = winner_team_id,
        team1_score = COALESCE($3, g.team1_score),
        team2_score = COALESCE($4, g.team2_score)
    WHERE g.id = game_id
    AND (g.team1_id = winner_team_id OR g.team2_id = winner_team_id)
    RETURNING g.id INTO error_info;  -- Capture if update succeeded
    
    GET DIAGNOSTICS update_result = ROW_COUNT;
    
    debug_info := debug_info || jsonb_build_object(
      'rows_updated', update_result,
      'update_attempted', TRUE,
      'update_returned_id', error_info
    );

    -- Log the update attempt
    INSERT INTO function_logs (function_name, params)
    VALUES (
      'advance_to_next_round_update',
      jsonb_build_object(
        'game_id', game_id,
        'rows_updated', update_result,
        'current_user', current_user,
        'current_timestamp', current_timestamp,
        'update_returned_id', error_info
      )
    );

  EXCEPTION WHEN OTHERS THEN
    error_info := SQLERRM;
    debug_info := debug_info || jsonb_build_object(
      'update_error', SQLERRM,
      'update_error_detail', SQLSTATE,
      'update_error_hint', SQLERRM,
      'error_context', error_info
    );
    
    -- Log the error
    INSERT INTO function_logs (function_name, params)
    VALUES (
      'advance_to_next_round_error',
      jsonb_build_object(
        'error', SQLERRM,
        'state', SQLSTATE,
        'context', error_info
      )
    );
  END;

  -- Get final game state
  SELECT 
    g.winner_id,
    g.team1_score as final_team1_score,
    g.team2_score as final_team2_score
  INTO game_info
  FROM games g
  WHERE g.id = game_id;

  debug_info := debug_info || jsonb_build_object(
    'final_game_state', jsonb_build_object(
      'winner_id', game_info.winner_id,
      'team1_score', game_info.final_team1_score,
      'team2_score', game_info.final_team2_score
    )
  );

  RETURN debug_info;
END;
$$ LANGUAGE plpgsql;

-- Ensure permissions are set
GRANT EXECUTE ON FUNCTION advance_to_next_round(UUID, UUID, INTEGER, INTEGER) TO anon;
GRANT UPDATE (winner_id, team1_score, team2_score) ON games TO anon; 