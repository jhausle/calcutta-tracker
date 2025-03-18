/*
  # Create calculate_and_insert_earnings procedure

  1. New Procedure
    - `calculate_and_insert_earnings(game_id uuid)`
      - Calculates and inserts earnings for the winning team's owner after a game
      - Parameters:
        - game_id: UUID of the game to process

  2. Functionality
    - Identifies winning team and owner
    - Gets season prize pool and round payout percentage
    - Calculates earnings
    - Inserts or updates owner earnings record
    
  3. Error Handling
    - Validates game exists and has a winner
    - Checks for required data (season, round, team)
    - Uses explicit error messages
*/

CREATE OR REPLACE PROCEDURE calculate_and_insert_earnings(p_game_id uuid)
LANGUAGE plpgsql
AS $$
DECLARE
  v_season_id uuid;
  v_round_id uuid;
  v_winner_id uuid;
  v_owner_id uuid;
  v_prize_pool numeric;
  v_payout_percentage numeric;
  v_amount_earned numeric;
BEGIN
  -- Get game details
  SELECT 
    g.season_id,
    g.round_id,
    g.winner_id
  INTO 
    v_season_id,
    v_round_id,
    v_winner_id
  FROM games g
  WHERE g.id = p_game_id;

  -- Validate game exists and has a winner
  IF v_winner_id IS NULL THEN
    RAISE EXCEPTION 'Game % does not exist or does not have a winner yet', p_game_id;
  END IF;

  -- Get the owner of the winning team
  SELECT owner_id
  INTO v_owner_id
  FROM teams
  WHERE id = v_winner_id;

  -- Validate team has an owner
  IF v_owner_id IS NULL THEN
    RAISE EXCEPTION 'Winning team % does not have an owner', v_winner_id;
  END IF;

  -- Get the prize pool for the season
  SELECT prize_pool
  INTO v_prize_pool
  FROM seasons
  WHERE id = v_season_id;

  -- Validate season exists and has a prize pool
  IF v_prize_pool IS NULL THEN
    RAISE EXCEPTION 'Season % not found or has no prize pool', v_season_id;
  END IF;

  -- Get the payout percentage for the round
  SELECT payout_percentage
  INTO v_payout_percentage
  FROM rounds
  WHERE id = v_round_id;

  -- Validate round exists and has a payout percentage
  IF v_payout_percentage IS NULL THEN
    RAISE EXCEPTION 'Round % not found or has no payout percentage', v_round_id;
  END IF;

  -- Calculate earnings (convert percentage to decimal)
  v_amount_earned := v_prize_pool * (v_payout_percentage / 100);

  -- Insert or update earnings record
  INSERT INTO owner_earnings (
    owner_id,
    team_id,
    season_id,
    round_id,
    amount_earned
  ) VALUES (
    v_owner_id,
    v_winner_id,
    v_season_id,
    v_round_id,
    v_amount_earned
  )
  ON CONFLICT (owner_id, team_id, season_id, round_id)
  DO UPDATE SET
    amount_earned = EXCLUDED.amount_earned;

END;
$$;