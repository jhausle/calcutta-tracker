/*
  # Allow public read access to all tables

  1. Changes
    - Update RLS policies for all tables to allow public read access
    - Keep RLS enabled but allow anonymous access
    - Affects tables:
      - owners
      - teams
      - team_results
      - rounds
      - seasons

  2. Security
    - Enables public read access to all tables
    - Maintains RLS but allows anonymous access
    - No authentication required for SELECT operations
*/

-- Update owners table policy
DROP POLICY IF EXISTS "Owners are viewable by all users" ON owners;
CREATE POLICY "Allow public read access to owners"
  ON owners
  FOR SELECT
  TO public
  USING (true);

-- Update teams table policy
DROP POLICY IF EXISTS "Teams are viewable by all users" ON teams;
CREATE POLICY "Allow public read access to teams"
  ON teams
  FOR SELECT
  TO public
  USING (true);

-- Update team_results table policy
DROP POLICY IF EXISTS "Team results are viewable by all users" ON team_results;
CREATE POLICY "Allow public read access to team_results"
  ON team_results
  FOR SELECT
  TO public
  USING (true);

-- Update rounds table policy
DROP POLICY IF EXISTS "Rounds are viewable by all users" ON rounds;
CREATE POLICY "Allow public read access to rounds"
  ON rounds
  FOR SELECT
  TO public
  USING (true);

-- Update seasons table policy
DROP POLICY IF EXISTS "Seasons are viewable by all users" ON seasons;
CREATE POLICY "Allow public read access to seasons"
  ON seasons
  FOR SELECT
  TO public
  USING (true);