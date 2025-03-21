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
  winner_region TEXT;
  should_be_team1 BOOLEAN;
  debug_info jsonb;
BEGIN
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
      -- First round: teams advance to same numbered game in next round
      IF current_game_number <= 16 THEN
        next_game_number := current_game_number;
        should_be_team1 := TRUE;
      ELSE
        next_game_number := 33 - current_game_number;
        should_be_team1 := FALSE;
      END IF;
    WHEN 2 THEN
      -- Second round: pairs of games combine
      next_game_number := ceiling(current_game_number / 2.0);
      should_be_team1 := (current_game_number % 2 = 1);
    WHEN 3 THEN
      -- Third round: regional finals
      next_game_number := ceiling(current_game_number / 2.0);
      should_be_team1 := (current_game_number % 2 = 1);
    WHEN 4 THEN
      -- Fourth round: final four
      next_game_number := ceiling(current_game_number / 2.0);
      should_be_team1 := (current_game_number % 2 = 1);
    ELSE
      -- Championship game has no next game
      RETURN jsonb_build_object('status', 'completed');
  END CASE;

  -- Find the next game
  SELECT g.id INTO next_game_id
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

  -- Update the next game with the winner
  IF next_game_id IS NOT NULL THEN
    IF should_be_team1 THEN
      UPDATE games 
      SET team1_id = winner_team_id
      WHERE id = next_game_id;
    ELSE
      UPDATE games 
      SET team2_id = winner_team_id
      WHERE id = next_game_id;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'status', 'advanced',
    'next_game_id', next_game_id,
    'next_game_number', next_game_number,
    'is_team1', should_be_team1
  );
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION advance_winner(UUID, UUID) TO anon; 