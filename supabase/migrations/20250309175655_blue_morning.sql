/*
  # Rename matchups table to games and add new columns

  1. Changes
    - Rename 'matchups' table to 'games'
    - Add 'winner_id' column (foreign key to teams)
    - Add 'game_date' column (timestamp with time zone)
    - Update RLS policies for the new table name

  2. Security
    - Maintain existing RLS settings
    - Add foreign key constraint for winner_id
*/

-- Rename the table
ALTER TABLE matchups RENAME TO games;

-- Add new columns
ALTER TABLE games 
  ADD COLUMN winner_id uuid REFERENCES teams(id),
  ADD COLUMN game_date timestamptz;

-- Recreate indexes with new table name
ALTER INDEX matchups_pkey RENAME TO games_pkey;
ALTER INDEX matchups_round_id_team1_id_season_id_key RENAME TO games_round_id_team1_id_season_id_key;
ALTER INDEX matchups_round_id_team2_id_season_id_key RENAME TO games_round_id_team2_id_season_id_key;

-- Rename foreign key constraints
ALTER TABLE games RENAME CONSTRAINT matchups_round_id_fkey TO games_round_id_fkey;
ALTER TABLE games RENAME CONSTRAINT matchups_season_id_fkey TO games_season_id_fkey;
ALTER TABLE games RENAME CONSTRAINT matchups_team1_id_fkey TO games_team1_id_fkey;
ALTER TABLE games RENAME CONSTRAINT matchups_team2_id_fkey TO games_team2_id_fkey;

-- Update RLS policies
ALTER TABLE games ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to games"
  ON games
  FOR SELECT
  TO public
  USING (true);