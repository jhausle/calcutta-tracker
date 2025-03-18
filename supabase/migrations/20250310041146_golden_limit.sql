/*
  # Add advance_to_next_round procedure

  1. New Functions
    - `advance_to_next_round(game_id uuid, winner_team_id uuid)`
      - Updates winner for current game
      - Creates or updates next round game with winner
      - Handles game progression based on tournament bracket structure

  2. Changes
    - Adds stored procedure for advancing winners through tournament rounds
    - Maintains bracket integrity by placing winners in correct next-round games
    - Updates owner earnings when games are won
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
  season_id uuid;
  current_game_number int;
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
    season_id,
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

  -- Create or update next round game
  IF current_game_number % 2 = 1 THEN
    -- First game of the pair - create new next round game
    INSERT INTO games (
      round_id,
      season_id,
      team1_id,
      game_number,
      game_date
    ) VALUES (
      next_round_id,
      season_id,
      winner_team_id,
      next_game_number,
      NOW() + INTERVAL '3 days'
    )
    ON CONFLICT (round_id, game_number, season_id)
    DO UPDATE SET
      team1_id = EXCLUDED.team1_id;
  ELSE
    -- Second game of the pair - update existing next round game
    UPDATE games
    SET team2_id = winner_team_id
    WHERE round_id = next_round_id
    AND game_number = next_game_number
    AND season_id = season_id;
  END IF;

  -- Calculate and insert earnings for the winning team's owner
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
  AND t.owner_id IS NOT NULL
  ON CONFLICT (owner_id, team_id, season_id, round_id)
  DO NOTHING;
END;
$$;