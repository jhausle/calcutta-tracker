/*
  # Fix advance_to_next_round procedure - Version 3

  1. Changes
    - Fixed bracket progression to maintain original tournament structure
    - Teams now advance according to their initial bracket position
    - Ensures proper matchups (e.g., #1 vs #32 winner, #8 vs #25 winner)
    - Orders games by overall seed to maintain bracket integrity
    
  2. Functionality
    - Uses overall_seed to determine matchups
    - Maintains bracket structure throughout tournament
    - Pairs winners based on original tournament seeding
    
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
  v_game_counter int := 1;
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
  -- Process games in order of overall seed to maintain bracket structure
  FOR v_game_counter IN 1..32 BY 2 LOOP
    WITH first_game AS (
      SELECT 
        g.id,
        g.winner_id,
        g.game_date,
        t.overall_seed
      FROM games g
      JOIN teams t ON t.id = g.team1_id
      WHERE g.season_id = p_season_id
        AND g.round_id = p_current_round_id
        AND t.overall_seed = v_game_counter
    ),
    second_game AS (
      SELECT 
        g.id,
        g.winner_id,
        g.game_date,
        t.overall_seed
      FROM games g
      JOIN teams t ON t.id = g.team1_id
      WHERE g.season_id = p_season_id
        AND g.round_id = p_current_round_id
        AND t.overall_seed = v_game_counter + 1
    )
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
      fg.winner_id,
      sg.winner_id,
      GREATEST(fg.game_date, sg.game_date) + interval '3 days'
    FROM first_game fg
    CROSS JOIN second_game sg;
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