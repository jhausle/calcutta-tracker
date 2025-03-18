/*
  # Tournament Database Schema

  1. New Tables
    - `owners`
      - `id` (uuid, primary key)
      - `name` (text)
      - `email` (text, unique)
      - `created_at` (timestamp)

    - `teams`
      - `id` (uuid, primary key)
      - `college` (text)
      - `region` (text)
      - `overall_seed` (integer)
      - `region_seed` (integer)
      - `owner_id` (uuid, foreign key)
      - `purchase_price` (integer)
      - `created_at` (timestamp)

    - `rounds`
      - `id` (uuid, primary key)
      - `name` (text)
      - `payout_percentage` (decimal)
      - `created_at` (timestamp)

    - `team_results`
      - `id` (uuid, primary key)
      - `team_id` (uuid, foreign key)
      - `round_id` (uuid, foreign key)
      - `won` (boolean)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create owners table
CREATE TABLE owners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE owners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners are viewable by all users"
  ON owners
  FOR SELECT
  TO authenticated
  USING (true);

-- Create teams table
CREATE TABLE teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  college text NOT NULL,
  region text NOT NULL,
  overall_seed integer NOT NULL,
  region_seed integer NOT NULL,
  owner_id uuid REFERENCES owners(id),
  purchase_price integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_region CHECK (region IN ('West', 'East', 'South', 'Midwest')),
  CONSTRAINT valid_overall_seed CHECK (overall_seed BETWEEN 1 AND 64),
  CONSTRAINT valid_region_seed CHECK (region_seed BETWEEN 1 AND 16)
);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teams are viewable by all users"
  ON teams
  FOR SELECT
  TO authenticated
  USING (true);

-- Create rounds table
CREATE TABLE rounds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  payout_percentage decimal NOT NULL,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_payout CHECK (payout_percentage BETWEEN 0 AND 1)
);

ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Rounds are viewable by all users"
  ON rounds
  FOR SELECT
  TO authenticated
  USING (true);

-- Insert round data
INSERT INTO rounds (name, payout_percentage) VALUES
  ('Round of 64', 0.01),
  ('Round of 32', 0.01),
  ('Sweet 16', 0.02),
  ('Elite 8', 0.04),
  ('Final Four', 0.06),
  ('Championship', 0.06);

-- Create team_results table
CREATE TABLE team_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid REFERENCES teams(id) NOT NULL,
  round_id uuid REFERENCES rounds(id) NOT NULL,
  won boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE team_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team results are viewable by all users"
  ON team_results
  FOR SELECT
  TO authenticated
  USING (true);

-- Create view for team earnings
CREATE VIEW team_earnings AS
SELECT 
  t.id as team_id,
  t.college,
  t.region,
  t.overall_seed,
  t.region_seed,
  t.purchase_price,
  o.name as owner_name,
  o.email as owner_email,
  COALESCE(SUM(CASE WHEN tr.won THEN r.payout_percentage * 5000 ELSE 0 END), 0) as total_earnings,
  COALESCE(SUM(CASE WHEN tr.won THEN r.payout_percentage * 5000 ELSE 0 END), 0) - t.purchase_price as net_profit
FROM teams t
LEFT JOIN owners o ON t.owner_id = o.id
LEFT JOIN team_results tr ON t.id = tr.team_id
LEFT JOIN rounds r ON tr.round_id = r.id
GROUP BY t.id, o.id;