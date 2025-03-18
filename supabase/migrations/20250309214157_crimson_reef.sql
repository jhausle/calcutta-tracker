/*
  # Update Round 1 Winners and Round 2 Matchups

  1. Purpose
    - Randomly select winners for Round 1 games
    - Update Round 2 matchups based on Round 1 winners
    
  2. Details
    - Uses current season (2024)
    - Randomly selects winners with higher seeds having better odds
    - Updates team_results table for Round 1
    - Pairs winners into Round 2 matchups
*/

DO $$
DECLARE
  v_season_id uuid;
  v_round1_id uuid;
  v_round2_id uuid;
  v_game record;
  v_winner_id uuid;
  v_round2_game_number int;
  v_existing_game_id uuid;
BEGIN
  -- Get the current season ID
  SELECT id INTO v_season_id FROM seasons WHERE year = 2024 LIMIT 1;
  
  -- Get round IDs
  SELECT id INTO v_round1_id FROM rounds WHERE name = 'Round of 64';
  SELECT id INTO v_round2_id FROM rounds WHERE name = 'Round of 32';

  -- First, clear any existing Round 2 team assignments to avoid conflicts
  UPDATE games
  SET team1_id = NULL, team2_id = NULL
  WHERE round_id = v_round2_id
  AND season_id = v_season_id;

  -- Process each Round 1 game
  FOR v_game IN 
    SELECT 
      g.id,
      g.game_number,
      g.team1_id,
      g.team2_id,
      t1.region_seed as seed1,
      t2.region_seed as seed2
    FROM games g
    JOIN teams t1 ON g.team1_id = t1.id
    JOIN teams t2 ON g.team2_id = t2.id
    WHERE g.round_id = v_round1_id
    AND g.season_id = v_season_id
    ORDER BY g.game_number
  LOOP
    -- Determine winner (higher seed has better odds)
    IF random() < (v_game.seed2::float / (v_game.seed1 + v_game.seed2)) THEN
      v_winner_id := v_game.team1_id;
    ELSE
      v_winner_id := v_game.team2_id;
    END IF;

    -- Update game with winner
    UPDATE games
    SET winner_id = v_winner_id
    WHERE id = v_game.id;

    -- Delete any existing results for these teams in this round
    DELETE FROM team_results
    WHERE team_id IN (v_game.team1_id, v_game.team2_id)
    AND round_id = v_round1_id
    AND season_id = v_season_id;

    -- Insert new team_results
    INSERT INTO team_results (team_id, round_id, season_id, won)
    VALUES
      (v_game.team1_id, v_round1_id, v_season_id, v_game.team1_id = v_winner_id),
      (v_game.team2_id, v_round1_id, v_season_id, v_game.team2_id = v_winner_id);

    -- Calculate Round 2 game number (pairs of Round 1 games)
    v_round2_game_number := ceil(v_game.game_number::float / 2);

    -- Get the existing Round 2 game
    SELECT id INTO v_existing_game_id
    FROM games
    WHERE round_id = v_round2_id
    AND season_id = v_season_id
    AND game_number = v_round2_game_number;

    -- Update Round 2 matchups
    IF v_game.game_number % 2 = 1 THEN
      -- First game of the pair - update team1
      UPDATE games
      SET team1_id = v_winner_id
      WHERE id = v_existing_game_id;
    ELSE
      -- Second game of the pair - update team2
      UPDATE games
      SET team2_id = v_winner_id
      WHERE id = v_existing_game_id;
    END IF;
  END LOOP;
END $$;