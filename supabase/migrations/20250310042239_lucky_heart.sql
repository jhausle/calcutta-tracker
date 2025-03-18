/*
  # Add Earnings Calculation Procedure and Trigger

  1. New Procedures and Functions
    - calculate_and_insert_earnings: Procedure to calculate and insert earnings for a team when they win a game
    - update_team_earnings: Trigger function to automatically calculate earnings when a game's winner is set

  2. Changes
    - Add trigger on games table to automatically calculate earnings when a winner is set
    - Recalculate existing earnings for all completed games

  3. Security
    - Procedures and functions execute with security definer to ensure proper access to tables
*/

-- Drop existing procedure if it exists
DROP PROCEDURE IF EXISTS calculate_and_insert_earnings(uuid);

-- Create the procedure to calculate and insert earnings
CREATE OR REPLACE PROCEDURE calculate_and_insert_earnings(game_id uuid)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_winner_id uuid;
    v_round_id uuid;
    v_season_id uuid;
    v_owner_id uuid;
    v_prize_pool numeric;
    v_payout_percentage numeric;
    v_earnings numeric;
BEGIN
    -- Get game details
    SELECT 
        winner_id,
        round_id,
        season_id
    INTO 
        v_winner_id,
        v_round_id,
        v_season_id
    FROM games
    WHERE id = game_id;

    -- Only proceed if there's a winner
    IF v_winner_id IS NOT NULL THEN
        -- Get the owner of the winning team
        SELECT owner_id
        INTO v_owner_id
        FROM teams
        WHERE id = v_winner_id;

        -- Only proceed if the team has an owner
        IF v_owner_id IS NOT NULL THEN
            -- Get season prize pool
            SELECT prize_pool::numeric
            INTO v_prize_pool
            FROM seasons
            WHERE id = v_season_id;

            -- Get round payout percentage
            SELECT payout_percentage
            INTO v_payout_percentage
            FROM rounds
            WHERE id = v_round_id;

            -- Calculate earnings
            v_earnings := v_prize_pool * v_payout_percentage;

            -- Insert or update earnings
            INSERT INTO owner_earnings (
                owner_id,
                team_id,
                season_id,
                round_id,
                amount_earned
            )
            VALUES (
                v_owner_id,
                v_winner_id,
                v_season_id,
                v_round_id,
                v_earnings
            )
            ON CONFLICT (owner_id, team_id, season_id, round_id)
            DO UPDATE SET
                amount_earned = EXCLUDED.amount_earned;
        END IF;
    END IF;
END;
$$;

-- Create trigger function to calculate earnings when a game's winner is set
CREATE OR REPLACE FUNCTION update_team_earnings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.winner_id IS NOT NULL AND (OLD.winner_id IS NULL OR OLD.winner_id != NEW.winner_id) THEN
        CALL calculate_and_insert_earnings(NEW.id);
    END IF;
    RETURN NEW;
END;
$$;

-- Add trigger to games table
DROP TRIGGER IF EXISTS calculate_earnings_trigger ON games;
CREATE TRIGGER calculate_earnings_trigger
    AFTER UPDATE OF winner_id ON games
    FOR EACH ROW
    EXECUTE FUNCTION update_team_earnings();

-- Recalculate earnings for all existing completed games
DO $$
DECLARE
    game_record RECORD;
BEGIN
    FOR game_record IN 
        SELECT id 
        FROM games 
        WHERE winner_id IS NOT NULL
    LOOP
        CALL calculate_and_insert_earnings(game_record.id);
    END LOOP;
END;
$$;