/*
  # Replace team_results with owner_earnings table

  1. Changes
    - Drop team_results table and its dependencies
    - Create new owner_earnings table to track earnings per team per round

  2. New Tables
    - `owner_earnings`
      - `id` (uuid, primary key)
      - `owner_id` (uuid, references owners)
      - `team_id` (uuid, references teams)
      - `season_id` (uuid, references seasons)
      - `round_id` (uuid, references rounds)
      - `amount_earned` (numeric, non-negative)
      - `created_at` (timestamptz)

  3. Security
    - Enable RLS on owner_earnings table
    - Add policy for public read access
    - Create indexes for common queries
*/

-- Drop the team_results table and its dependencies
DROP VIEW IF EXISTS team_earnings;
DROP TABLE IF EXISTS team_results;

-- Create the new owner_earnings table
CREATE TABLE IF NOT EXISTS owner_earnings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES owners(id),
  team_id uuid NOT NULL REFERENCES teams(id),
  season_id uuid NOT NULL REFERENCES seasons(id),
  round_id uuid NOT NULL REFERENCES rounds(id),
  amount_earned numeric NOT NULL CHECK (amount_earned >= 0),
  created_at timestamptz DEFAULT now(),
  UNIQUE(owner_id, team_id, season_id, round_id)
);

-- Enable RLS
ALTER TABLE owner_earnings ENABLE ROW LEVEL SECURITY;

-- Add policy for public read access
CREATE POLICY "Allow public read access to owner_earnings"
  ON owner_earnings
  FOR SELECT
  TO public
  USING (true);

-- Create indexes for common queries
CREATE INDEX owner_earnings_owner_id_idx ON owner_earnings(owner_id);
CREATE INDEX owner_earnings_team_id_idx ON owner_earnings(team_id);
CREATE INDEX owner_earnings_season_id_idx ON owner_earnings(season_id);
CREATE INDEX owner_earnings_round_id_idx ON owner_earnings(round_id);