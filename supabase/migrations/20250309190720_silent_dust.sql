/*
  # Create advance_to_next_round procedure

  1. New Procedure
    - `advance_to_next_round(p_season_id uuid, p_current_round_id uuid)`
      - Advances teams to the next tournament round by creating new games
      - Parameters:
        - p_season_id: UUID of the current season
        - p_current_round_id: UUID of the current round

  2. Functionality
    - Validates all current round games are complete
    - Identifies the next round based on round_number
    - Creates new games pairing winners from current round
    - Sets game dates for the next round
    
  3. Error Handling
    - Validates all games have winners
    - Checks round progression is valid
    - Uses explicit error messages
*/

CREATE OR REPLACE PROCEDURE advance_to_next_round(p_season_id uuid, p_current_round_id uuid)
LANGUAGE plpgsql
AS $$
DECLARE
  v_next_round_id uuid;
  v_current_round_number int;
  v_incomplete_games int;
  v_game record;
  v_game_counter int := 0;
BEGIN
  -- Get the current round number
  SELECT round_number INTO v_current_round_number
  FROM rounds
  WHERE id = p_current_round_id;

  IF v_current_round_number IS NULL THEN
    RAISE EXCEPTION 'Invalid round ID provided';
  END IF;

  -- Get the next round ID
  SELECT id INTO v_next_round_id
  FROM rounds
  WHERE round_number = v_current_round_number + 1;

  IF v_next_round_id IS NULL THEN
    RAISE EXCEPTION 'Next round not found';
  END IF;

  -- Check if all games in the current round are completed
  SELECT COUNT(*) INTO v_incomplete_games
  FROM games
  WHERE season_id = p_season_id
    AND round_id = p_current_round_id
    AND winner_id IS NULL;

  IF v_incomplete_games > 0 THEN
    RAISE EXCEPTION 'Not all games in the current round are completed (% games pending)', v_incomplete_games;
  END IF;

  -- Delete any existing games in the next round (in case we need to regenerate)
  DELETE FROM games
  WHERE season_id = p_season_id
    AND round_id = v_next_round_id;

  -- Create games for the next round by pairing winners
  FOR v_game IN (
    SELECT 
      id,
      winner_id,
      ROW_NUMBER() OVER (ORDER BY game_date) AS game_order
    FROM games
    WHERE season_id = p_season_id
      AND round_id = p_current_round_id
    ORDER BY game_date
  )
  LOOP
    v_game_counter := v_game_counter + 1;
    
    -- For every two games, create one new game
    IF v_game_counter % 2 = 0 THEN
      -- Get the previous game's winner (our team1)
      WITH prev_winner AS (
        SELECT winner_id AS team1_id
        FROM games
        WHERE season_id = p_season_id
          AND round_id = p_current_round_id
          AND ROW_NUMBER() OVER (ORDER BY game_date) = v_game_counter - 1
      )
      -- Insert the new game
      INSERT INTO games (
        season_id,
        round_id,
        team1_id,
        team2_id,
        game_date
      )
      SELECT 
        p_season_id,
        v_next_round_id,
        prev_winner.team1_id,
        v_game.winner_id,
        -- Set game date to 3 days after the last game of the pair
        v_game.game_date::timestamp + interval '3 days'
      FROM prev_winner;
    END IF;
  END LOOP;

  -- Verify we created the correct number of games
  IF (
    SELECT COUNT(*)
    FROM games
    WHERE season_id = p_season_id
      AND round_id = v_next_round_id
  ) != (
    SELECT COUNT(*) / 2
    FROM games
    WHERE season_id = p_season_id
      AND round_id = p_current_round_id
  ) THEN
    RAISE EXCEPTION 'Failed to create the correct number of games for the next round';
  END IF;
END;
$$;