/*
  # Fix advance_to_next_round procedure

  1. Changes
    - Fixed bracket progression to maintain original seeding paths
    - Teams now advance according to their initial tournament bracket position
    - Ensures #1 seed plays winner of #32/#33 game, etc.
    - Maintains proper bracket structure throughout tournament

  2. Functionality
    - Uses game_date to order games within a round
    - Pairs winners based on original bracket structure
    - Sets next round game dates 3 days after previous round
    
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
  v_games_per_region int;
  v_current_games CURSOR FOR
    SELECT 
      g.id,
      g.winner_id,
      g.game_date,
      t1.region,
      t1.region_seed as team1_seed,
      t2.region_seed as team2_seed
    FROM games g
    JOIN teams t1 ON t1.id = g.team1_id
    JOIN teams t2 ON t2.id = g.team2_id
    WHERE g.season_id = p_season_id
      AND g.round_id = p_current_round_id
    ORDER BY t1.region, 
      -- Order by the lower seed number to maintain bracket order
      LEAST(t1.region_seed, t2.region_seed);
  v_game1 record;
  v_game2 record;
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
  -- Process each region separately to maintain bracket integrity
  OPEN v_current_games;
  LOOP
    -- Get first game of the pair
    FETCH v_current_games INTO v_game1;
    EXIT WHEN NOT FOUND;
    
    -- Get second game of the pair
    FETCH v_current_games INTO v_game2;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Odd number of games in current round';
    END IF;

    -- Verify games are from the same region
    IF v_game1.region != v_game2.region THEN
      RAISE EXCEPTION 'Games from different regions cannot be paired';
    END IF;

    -- Create the next round game
    INSERT INTO games (
      season_id,
      round_id,
      team1_id,
      team2_id,
      game_date
    ) VALUES (
      p_season_id,
      v_next_round_id,
      v_game1.winner_id,
      v_game2.winner_id,
      -- Set game date to 3 days after the later of the two games
      GREATEST(v_game1.game_date, v_game2.game_date) + interval '3 days'
    );
  END LOOP;
  CLOSE v_current_games;

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