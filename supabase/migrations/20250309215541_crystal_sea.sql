/*
  # Update Round of 32 matchups

  1. Purpose
    - Fill in Round of 32 matchups based on Round of 64 winners
    
  2. Details
    - Gets winners from Round of 64 games
    - Updates Round of 32 games with winning teams
    - Matches are paired based on game numbers (1-2 go to game 1, 3-4 to game 2, etc.)
*/

DO $$
DECLARE
  v_season_id uuid;
  v_round64_id uuid;
  v_round32_id uuid;
  v_game record;
BEGIN
  -- Get the current season ID
  SELECT id INTO v_season_id 
  FROM seasons 
  WHERE year = 2024 
  LIMIT 1;

  -- Get round IDs
  SELECT id INTO v_round64_id 
  FROM rounds 
  WHERE name = 'Round of 64';

  SELECT id INTO v_round32_id 
  FROM rounds 
  WHERE name = 'Round of 32';

  -- Update Round of 32 games with winners from Round of 64
  FOR v_game IN 
    SELECT 
      g.game_number,
      g.winner_id
    FROM games g
    WHERE g.round_id = v_round64_id
    AND g.season_id = v_season_id
    AND g.winner_id IS NOT NULL
    ORDER BY g.game_number
  LOOP
    -- For odd-numbered games, update team1
    IF v_game.game_number % 2 = 1 THEN
      UPDATE games
      SET team1_id = v_game.winner_id
      WHERE round_id = v_round32_id
      AND season_id = v_season_id
      AND game_number = ceil(v_game.game_number::float / 2);
    -- For even-numbered games, update team2
    ELSE
      UPDATE games
      SET team2_id = v_game.winner_id
      WHERE round_id = v_round32_id
      AND season_id = v_season_id
      AND game_number = v_game.game_number / 2;
    END IF;
  END LOOP;
END $$;