/*
  # Add matchups table for tournament games

  1. New Tables
    - `matchups`
      - `id` (uuid, primary key)
      - `round_id` (uuid, references rounds)
      - `season_id` (uuid, references seasons)
      - `team1_id` (uuid, references teams)
      - `team2_id` (uuid, references teams)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `matchups` table
    - Add policy for public read access
*/

CREATE TABLE IF NOT EXISTS matchups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  round_id uuid NOT NULL REFERENCES rounds(id),
  season_id uuid NOT NULL REFERENCES seasons(id),
  team1_id uuid NOT NULL REFERENCES teams(id),
  team2_id uuid NOT NULL REFERENCES teams(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(round_id, team1_id, season_id),
  UNIQUE(round_id, team2_id, season_id)
);

ALTER TABLE matchups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to matchups"
  ON matchups
  FOR SELECT
  TO public
  USING (true);