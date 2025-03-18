/*
  # Fix Game Winner and Championship Handling

  1. New Functions
    - advance_to_next_round: Function to handle game progression and championship
      - Updates winner_id in games table
      - Updates season champion if championship game
      - Creates next round game for non-championship games

  2. Changes
    - Add explicit winner_id update
    - Add championship handling
    - Add season champion update
    - Add game progression logic

  3. Security
    - Functions execute with security definer to ensure proper access
*/

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS advance_to_next_round(uuid, uuid);

-- Create function to handle game progression and championship
CREATE OR REPLACE FUNCTION advance_to_next_round(
    game_id uuid,
    winner_team_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_round_id uuid;
    v_season_id uuid;
    v_round_name text;
    v_next_round_id uuid;
    v_next_game_number int;
    v_next_team_position int;
BEGIN
    -- First, update the winner_id in the games table
    UPDATE games
    SET winner_id = winner_team_id
    WHERE id = game_id;

    -- Get current game details
    SELECT 
        g.round_id,
        g.season_id,
        r.name
    INTO 
        v_round_id,
        v_season_id,
        v_round_name
    FROM games g
    JOIN rounds r ON r.id = g.round_id
    WHERE g.id = game_id;

    -- Check if this is the championship game
    IF v_round_name = 'Championship' THEN
        -- Update the season's champion
        UPDATE seasons
        SET champion_team_id = winner_team_id
        WHERE id = v_season_id;
        RETURN;
    END IF;

    -- Get the next round information
    SELECT id
    INTO v_next_round_id
    FROM rounds r
    WHERE 
        CASE v_round_name
            WHEN 'Round of 64' THEN r.name = 'Round of 32'
            WHEN 'Round of 32' THEN r.name = 'Sweet 16'
            WHEN 'Sweet 16' THEN r.name = 'Elite 8'
            WHEN 'Elite 8' THEN r.name = 'Final Four'
            WHEN 'Final Four' THEN r.name = 'Championship'
            ELSE NULL
        END;

    IF v_next_round_id IS NULL THEN
        RETURN;
    END IF;

    -- Get the next available game number in the next round
    SELECT COALESCE(MAX(game_number), 0) + 1
    INTO v_next_game_number
    FROM games
    WHERE round_id = v_next_round_id
    AND season_id = v_season_id;

    -- Determine which position (1 or 2) this winner should take in the next game
    SELECT 
        CASE 
            WHEN game_number % 2 = 1 THEN 1  -- Odd numbered games go to position 1
            ELSE 2                           -- Even numbered games go to position 2
        END
    INTO v_next_team_position
    FROM games
    WHERE id = game_id;

    -- Create the next round game or update existing one
    IF v_next_team_position = 1 THEN
        -- Create new game with winner as team1
        INSERT INTO games (
            round_id,
            season_id,
            team1_id,
            game_number
        ) VALUES (
            v_next_round_id,
            v_season_id,
            winner_team_id,
            v_next_game_number
        );
    ELSE
        -- Update existing game with winner as team2
        UPDATE games
        SET team2_id = winner_team_id
        WHERE round_id = v_next_round_id
        AND season_id = v_season_id
        AND game_number = v_next_game_number - 1
        AND team2_id IS NULL;
    END IF;
END;
$$;