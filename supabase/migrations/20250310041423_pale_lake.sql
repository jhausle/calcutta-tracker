/*
  # Fix advance_to_next_round procedure

  1. Changes
    - Remove problematic ON CONFLICT clause
    - Add proper unique constraint handling
    - Fix game progression logic
    - Improve error handling
*/

CREATE OR REPLACE FUNCTION public.advance_to_next_round(
  game_id uuid,
  winner_team_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_round_id uuid;
  current_round_number int;
  next_round_id uuid;
  next_game_number int;
  current_season_id uuid;
  current_game_number int;
  existing_next_game_id uuid;
BEGIN
  -- Get current game info
  SELECT 
    g.round_id, 
    r.round_number,
    g.season_id,
    g.game_number
  INTO 
    current_round_id,
    current_round_number,
    current_season_id,
    current_game_number
  FROM games g
  JOIN rounds r ON r.id = g.round_id
  WHERE g.id = game_id;

  -- Get next round
  SELECT id 
  INTO next_round_id
  FROM rounds
  WHERE round_number = current_round_number + 1;

  -- Calculate next game number
  -- Each pair of games (1-2, 3-4, etc) feeds into the next round
  next_game_number := (current_game_number + 1) / 2;

  -- Check if next round game already exists
  SELECT id
  INTO existing_next_game_id
  FROM games
  WHERE round_id = next_round_id
  AND game_number = next_game_number
  AND season_id = current_season_id;

  -- Create or update next round game
  IF current_game_number % 2 = 1 THEN
    -- First game of the pair
    IF existing_next_game_id IS NULL THEN
      -- Create new game
      INSERT INTO games (
        round_id,
        season_id,
        team1_id,
        game_number,
        game_date
      ) VALUES (
        next_round_id,
        current_season_id,
        winner_team_id,
        next_game_number,
        NOW() + INTERVAL '3 days'
      );
    ELSE
      -- Update existing game
      UPDATE games
      SET team1_id = winner_team_id
      WHERE id = existing_next_game_id;
    END IF;
  ELSE
    -- Second game of the pair
    IF existing_next_game_id IS NOT NULL THEN
      UPDATE games
      SET team2_id = winner_team_id
      WHERE id = existing_next_game_id;
    END IF;
  END IF;

  -- Update the winner in the current game
  UPDATE games
  SET winner_id = winner_team_id
  WHERE id = game_id;

  -- Calculate and insert earnings if not already recorded
  IF NOT EXISTS (
    SELECT 1 
    FROM owner_earnings 
    WHERE team_id = winner_team_id 
    AND round_id = current_round_id
    AND season_id = current_season_id
  ) THEN
    INSERT INTO owner_earnings (
      owner_id,
      team_id,
      season_id,
      round_id,
      amount_earned
    )
    SELECT 
      t.owner_id,
      t.id,
      t.season_id,
      current_round_id,
      s.prize_pool * r.payout_percentage
    FROM teams t
    JOIN seasons s ON s.id = t.season_id
    JOIN rounds r ON r.id = current_round_id
    WHERE t.id = winner_team_id
    AND t.owner_id IS NOT NULL;
  END IF;
END;
$$;