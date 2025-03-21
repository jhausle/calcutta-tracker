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
BEGIN
  -- Get the current game info
  SELECT 
    g.game_number,
    r.round_number
  INTO 
    current_game_number,
    current_round
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  WHERE g.id = game_id;

  -- Calculate next game number and position
  next_game_number := ceiling(current_game_number / 2.0);
  -- For each pair of games going to the same next game:
  -- Lower numbered game (2n-1) goes to team1
  -- Higher numbered game (2n) goes to team2
  should_be_team1 := (current_game_number = (2 * next_game_number - 1));

  debug_info := jsonb_build_object(
    'advancement_calc', jsonb_build_object(
      'current_game', current_game_number,
      'current_round', current_round,
      'next_game_number', next_game_number,
      'should_be_team1', should_be_team1,
      'expected_team1_game', (2 * next_game_number - 1),
      'expected_team2_game', (2 * next_game_number)
    )
  );

  -- Find the next game
  SELECT g.id INTO next_game_id
  FROM games g
  JOIN rounds r ON g.round_id = r.id
  WHERE r.round_number = current_round + 1
    AND g.game_number = next_game_number;

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