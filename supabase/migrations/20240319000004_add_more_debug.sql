DROP FUNCTION IF EXISTS advance_to_next_round;

CREATE OR REPLACE FUNCTION advance_to_next_round(
  game_id UUID,
  winner_team_id UUID,
  team1_score INTEGER DEFAULT NULL,
  team2_score INTEGER DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
  next_game_id UUID;
  current_game_number INTEGER;
  next_game_number INTEGER;
  current_round INTEGER;
  winner_region TEXT;
  should_be_team1 BOOLEAN;
  debug_info jsonb;
BEGIN
  -- Update the current game with the winner and scores
  UPDATE games 
  SET winner_id = winner_team_id,
      team1_score = COALESCE($3, games.team1_score),
      team2_score = COALESCE($4, games.team2_score)
  WHERE id = game_id
  RETURNING id INTO debug_info;

  debug_info := jsonb_build_object(
    'initial_update', debug_info IS NOT NULL,
    'game_id', game_id,
    'winner_team_id', winner_team_id
  );

  -- Get the current game info
  SELECT jsonb_build_object(
    'game_number', g.game_number,
    'round_number', r.round_number,
    'region', t.region,
    'game_found', g.id IS NOT NULL,
    'round_found', r.id IS NOT NULL,
    'team_found', t.id IS NOT NULL
  )
  INTO debug_info
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  JOIN teams t ON t.id = winner_team_id
  WHERE g.id = game_id;

  -- Store values for further processing
  current_game_number := (debug_info->>'game_number')::integer;
  current_round := (debug_info->>'round_number')::integer;
  winner_region := debug_info->>'region';

  -- Calculate next game number and position
  CASE current_round
    WHEN 1 THEN
      IF current_game_number <= 16 THEN
        next_game_number := current_game_number;
        should_be_team1 := TRUE;
      ELSE
        next_game_number := 33 - current_game_number;
        should_be_team1 := FALSE;
      END IF;
    -- ... rest of the CASE statement ...
  END CASE;

  debug_info := debug_info || jsonb_build_object(
    'calculated_next_game', next_game_number,
    'should_be_team1', should_be_team1
  );

  -- Find the next game
  SELECT jsonb_build_object(
    'next_game_id', g.id,
    'next_game_number', g.game_number,
    'next_round_number', r.round_number,
    'team1_region', t1.region,
    'team2_region', t2.region
  )
  INTO debug_info
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  LEFT JOIN teams t1 ON g.team1_id = t1.id
  LEFT JOIN teams t2 ON g.team2_id = t2.id
  WHERE r.round_number = current_round + 1
    AND g.game_number = next_game_number
    AND (
      (current_round = 1 AND (t1.region = winner_region OR t2.region = winner_region)) OR
      (current_round > 1)
    );

  RETURN debug_info;
END;
$$ LANGUAGE plpgsql; 