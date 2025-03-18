/*
  # Add earnings calculation function

  1. Changes
    - Creates a function to calculate and update owner earnings when a team wins a game
    - Handles earnings based on round progression
    - Updates owner_earnings table with new earnings

  2. Security
    - Function runs with SECURITY DEFINER to ensure proper access
    - Execute permission granted to authenticated users
*/

-- Function to calculate and update earnings for a winning team
CREATE OR REPLACE FUNCTION calculate_and_update_earnings(
  game_id UUID,
  winner_team_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_round_id UUID;
  v_season_id UUID;
  v_owner_id UUID;
  v_prize_pool INTEGER;
  v_payout_percentage NUMERIC;
  v_earnings NUMERIC;
BEGIN
  -- Get game details
  SELECT 
    g.round_id,
    g.season_id,
    t.owner_id
  INTO 
    v_round_id,
    v_season_id,
    v_owner_id
  FROM games g
  JOIN teams t ON t.id = winner_team_id
  WHERE g.id = game_id;

  -- Get season prize pool
  SELECT prize_pool
  INTO v_prize_pool
  FROM seasons
  WHERE id = v_season_id;

  -- Get round payout percentage
  SELECT payout_percentage
  INTO v_payout_percentage
  FROM rounds
  WHERE id = v_round_id;

  -- Calculate earnings for this round
  v_earnings := v_prize_pool * v_payout_percentage;

  -- Insert or update owner earnings
  INSERT INTO owner_earnings (
    owner_id,
    team_id,
    season_id,
    round_id,
    amount_earned
  ) VALUES (
    v_owner_id,
    winner_team_id,
    v_season_id,
    v_round_id,
    v_earnings
  )
  ON CONFLICT (owner_id, team_id, season_id, round_id) 
  DO UPDATE SET
    amount_earned = EXCLUDED.amount_earned;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION calculate_and_update_earnings(UUID, UUID) TO authenticated;

-- Update the advance_to_next_round function to also calculate earnings
CREATE OR REPLACE FUNCTION advance_to_next_round(
  game_id UUID,
  winner_team_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_round_number INTEGER;
  next_round_id UUID;
  next_game_number INTEGER;
  team_position INTEGER;
  current_game_number INTEGER;
  current_season_id UUID;
BEGIN
  -- Calculate earnings for the winning team
  PERFORM calculate_and_update_earnings(game_id, winner_team_id);

  -- Get the current game's round number, game number, and season
  SELECT 
    r.round_number,
    g.game_number,
    g.season_id
  INTO 
    current_round_number,
    current_game_number,
    current_season_id
  FROM games g
  JOIN rounds r ON r.id = g.round_id
  WHERE g.id = game_id;

  -- Get the next round's ID
  SELECT id 
  INTO next_round_id
  FROM rounds
  WHERE round_number = current_round_number + 1;

  -- If there's no next round, we're done
  IF next_round_id IS NULL THEN
    RETURN;
  END IF;

  -- Calculate the next game number and team position
  next_game_number := (current_game_number + 1) / 2;
  team_position := CASE 
    WHEN current_game_number % 2 = 1 THEN 1 
    ELSE 2 
  END;

  -- Check if the next game already exists
  IF EXISTS (
    SELECT 1 
    FROM games 
    WHERE round_id = next_round_id 
    AND game_number = next_game_number
    AND season_id = current_season_id
  ) THEN
    -- Update existing game with the winner in the correct position
    IF team_position = 1 THEN
      UPDATE games 
      SET team1_id = winner_team_id
      WHERE round_id = next_round_id 
      AND game_number = next_game_number
      AND season_id = current_season_id;
    ELSE
      UPDATE games 
      SET team2_id = winner_team_id
      WHERE round_id = next_round_id 
      AND game_number = next_game_number
      AND season_id = current_season_id;
    END IF;
  ELSE
    -- Create new game with the winner in the correct position
    INSERT INTO games (
      round_id,
      season_id,
      game_number,
      team1_id,
      team2_id
    ) VALUES (
      next_round_id,
      current_season_id,
      next_game_number,
      CASE WHEN team_position = 1 THEN winner_team_id ELSE NULL END,
      CASE WHEN team_position = 2 THEN winner_team_id ELSE NULL END
    );
  END IF;
END;
$$;