/*
  # Add Seasons Support

  1. New Tables
    - `seasons`
      - `id` (uuid, primary key)
      - `year` (integer)
      - `name` (text)
      - `prize_pool` (integer)
      - `created_at` (timestamp)

  2. Changes
    - Add `season_id` to `teams` table
    - Add `season_id` to `team_results` table
    - Update team_earnings view to include season information

  3. Security
    - Enable RLS on seasons table
    - Add policies for authenticated users
*/

-- Create seasons table
CREATE TABLE seasons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year integer NOT NULL,
  name text NOT NULL,
  prize_pool integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_year CHECK (year >= 2024),
  CONSTRAINT valid_prize_pool CHECK (prize_pool > 0)
);

ALTER TABLE seasons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Seasons are viewable by all users"
  ON seasons
  FOR SELECT
  TO authenticated
  USING (true);

-- Add season_id to teams table
ALTER TABLE teams 
ADD COLUMN season_id uuid REFERENCES seasons(id) NOT NULL;

-- Add season_id to team_results table
ALTER TABLE team_results 
ADD COLUMN season_id uuid REFERENCES seasons(id) NOT NULL;

-- Drop existing team_earnings view
DROP VIEW IF EXISTS team_earnings;

-- Create updated team_earnings view with season information
CREATE VIEW team_earnings AS
SELECT 
  t.id as team_id,
  s.id as season_id,
  s.year as season_year,
  s.name as season_name,
  s.prize_pool,
  t.college,
  t.region,
  t.overall_seed,
  t.region_seed,
  t.purchase_price,
  o.name as owner_name,
  o.email as owner_email,
  COALESCE(SUM(CASE WHEN tr.won THEN r.payout_percentage * s.prize_pool ELSE 0 END), 0) as total_earnings,
  COALESCE(SUM(CASE WHEN tr.won THEN r.payout_percentage * s.prize_pool ELSE 0 END), 0) - t.purchase_price as net_profit
FROM teams t
JOIN seasons s ON t.season_id = s.id
LEFT JOIN owners o ON t.owner_id = o.id
LEFT JOIN team_results tr ON t.id = tr.team_id AND tr.season_id = s.id
LEFT JOIN rounds r ON tr.round_id = r.id
GROUP BY t.id, s.id, o.id;