CREATE OR REPLACE FUNCTION advance_winner(
  game_id UUID,
  winner_team_id UUID
)
RETURNS jsonb AS $$
DECLARE
  next_game_id UUID;
  current_game_number INTEGER;
  next_game_number INTEGER;
  current_round INTEGER;
  should_be_team1 BOOLEAN;
  debug_info jsonb;
  total_games INTEGER;
  original_game INTEGER;
BEGIN
  -- Get the current game info with round number
  SELECT 
    g.game_number,
    r.round_number,
    (SELECT COUNT(*) FROM games g2 WHERE g2.round_id = g.round_id) as games_in_round
  INTO 
    current_game_number,
    current_round,
    total_games
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  WHERE g.id = game_id;

  -- Store original game number for debugging
  original_game := current_game_number;

  -- Calculate next game number and position
  next_game_number := ceiling(current_game_number / 2.0);
  -- For each pair of games going to the same next game:
  -- Odd numbered games go to team1, even to team2
  should_be_team1 := (current_game_number % 2 = 1);

  debug_info := jsonb_build_object(
    'advancement_calc', jsonb_build_object(
      'original_game', original_game,
      'total_games_in_round', total_games,
      'current_round', current_round,
      'next_game_number', next_game_number,
      'should_be_team1', should_be_team1,
      'is_odd_game', (current_game_number % 2 = 1)
    )
  );

  -- Find the next game using round_number
  SELECT g.id 
  INTO next_game_id
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  WHERE r.round_number = current_round + 1
    AND g.game_number = next_game_number;

  -- Get available games info for debugging
  WITH round_games AS (
    SELECT 
      r.round_number,
      array_agg(g.game_number ORDER BY g.game_number) as game_numbers
    FROM games g
    JOIN rounds r ON g.round_id = r.id
    GROUP BY r.round_number
    ORDER BY r.round_number
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'round', round_number,
      'games', game_numbers
    )
  ) INTO debug_info
  FROM round_games;

  debug_info := debug_info || jsonb_build_object(
    'next_game_search', jsonb_build_object(
      'found_game_id', next_game_id IS NOT NULL,
      'next_game_id', next_game_id,
      'search_criteria', jsonb_build_object(
        'target_round', current_round + 1,
        'target_game_number', next_game_number
      )
    )
  );

  -- Update the next game with the winner
  IF next_game_id IS NOT NULL THEN
    IF should_be_team1 THEN
      UPDATE games 
      SET team1_id = winner_team_id
      WHERE id = next_game_id
      RETURNING id INTO next_game_id;
    ELSE
      UPDATE games 
      SET team2_id = winner_team_id
      WHERE id = next_game_id
      RETURNING id INTO next_game_id;
    END IF;

    debug_info := debug_info || jsonb_build_object(
      'update_result', jsonb_build_object(
        'next_game_id', next_game_id,
        'updated_as_team1', should_be_team1,
        'winner_placed', next_game_id IS NOT NULL
      )
    );
  END IF;

  RETURN debug_info;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION advance_winner(UUID, UUID) TO anon; 