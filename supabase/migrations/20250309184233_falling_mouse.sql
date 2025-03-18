/*
  # Update Generate Round 1 Games Procedure

  1. Changes
    - Drop existing procedure
    - Recreate procedure with clearer parameter naming
    - Add explicit table references to avoid ambiguity
    - Improve error handling and validation

  2. Implementation Details
    - Takes season_id_input as input parameter
    - Creates games for all regions with proper seeding matchups
    - Validates data and handles errors
*/

-- First drop the existing procedure
DROP PROCEDURE IF EXISTS generate_round1_games(uuid);

-- Then create the new procedure
CREATE OR REPLACE PROCEDURE generate_round1_games(season_id_input uuid)
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
  IF NOT EXISTS (SELECT 1 FROM seasons WHERE id = season_id_input) THEN
    RAISE EXCEPTION 'Season not found';
  END IF;

  -- Delete any existing Round 1 games for this season
  DELETE FROM games
  WHERE games.season_id = season_id_input
  AND games.round_id = v_round_id;

  -- Create games for each region
  FOREACH v_region IN ARRAY v_regions
  LOOP
    -- Create games for each seed matchup
    FOR i IN 1..array_length(v_matchups, 1)
    LOOP
      -- Get team IDs for the matchup
      SELECT id INTO v_team1_id
      FROM teams
      WHERE teams.season_id = season_id_input
      AND teams.region = v_region
      AND teams.region_seed = v_matchups[i][1];

      SELECT id INTO v_team2_id
      FROM teams
      WHERE teams.season_id = season_id_input
      AND teams.region = v_region
      AND teams.region_seed = v_matchups[i][2];

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
        season_id_input,
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
    WHERE games.season_id = season_id_input
    AND games.round_id = v_round_id
  ) != 32 THEN
    RAISE EXCEPTION 'Failed to create all 32 Round 1 games';
  END IF;
END;
$$;