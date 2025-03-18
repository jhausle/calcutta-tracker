/*
  # Create Generate Round 1 Games Procedure

  1. New Procedure
    - Creates a stored procedure to generate Round 1 tournament games
    - Handles proper NCAA tournament seeding matchups (1v16, 2v15, etc)
    - Creates games for all four regions
    - Validates team availability and proper seeding

  2. Implementation Details
    - Takes season_id as input parameter
    - Validates required data exists
    - Creates games with proper seed matchups
    - Handles error cases gracefully
*/

CREATE OR REPLACE PROCEDURE generate_round1_games(season_id uuid)
LANGUAGE plpgsql
AS $$
DECLARE
  v_round_id uuid;
  v_region text;
  v_team1_id uuid;
  v_team2_id uuid;
  v_regions text[] := ARRAY['West', 'East', 'South', 'Midwest'];
  v_matchups int[][] := ARRAY[
    [1, 16],
    [8, 9],
    [5, 12],
    [4, 13],
    [6, 11],
    [3, 14],
    [7, 10],
    [2, 15]
  ];
BEGIN
  -- Get the Round of 64 ID
  SELECT id INTO v_round_id
  FROM rounds
  WHERE round_number = 1;

  IF v_round_id IS NULL THEN
    RAISE EXCEPTION 'Round 1 not found in rounds table';
  END IF;

  -- Verify season exists
  IF NOT EXISTS (SELECT 1 FROM seasons WHERE id = season_id) THEN
    RAISE EXCEPTION 'Season not found';
  END IF;

  -- Delete any existing Round 1 games for this season
  DELETE FROM games
  WHERE season_id = generate_round1_games.season_id
  AND round_id = v_round_id;

  -- Create games for each region
  FOREACH v_region IN ARRAY v_regions
  LOOP
    -- Create games for each seed matchup
    FOR i IN 1..array_length(v_matchups, 1)
    LOOP
      -- Get team IDs for the matchup
      SELECT id INTO v_team1_id
      FROM teams
      WHERE season_id = generate_round1_games.season_id
      AND region = v_region
      AND region_seed = v_matchups[i][1];

      SELECT id INTO v_team2_id
      FROM teams
      WHERE season_id = generate_round1_games.season_id
      AND region = v_region
      AND region_seed = v_matchups[i][2];

      -- Validate both teams exist
      IF v_team1_id IS NULL OR v_team2_id IS NULL THEN
        RAISE EXCEPTION 'Missing teams for % region, seeds % and %',
          v_region, v_matchups[i][1], v_matchups[i][2];
      END IF;

      -- Create the game
      INSERT INTO games (
        season_id,
        round_id,
        team1_id,
        team2_id,
        game_date
      ) VALUES (
        generate_round1_games.season_id,
        v_round_id,
        v_team1_id,
        v_team2_id,
        now() + (i || ' days')::interval -- Spread games across days
      );
    END LOOP;
  END LOOP;

  -- Verify all games were created
  IF (
    SELECT count(*)
    FROM games
    WHERE season_id = generate_round1_games.season_id
    AND round_id = v_round_id
  ) != 32 THEN
    RAISE EXCEPTION 'Failed to create all 32 Round 1 games';
  END IF;
END;
$$;