/*
  # Create team results and earnings tracking

  1. New Tables
    - `team_results`: Tracks team wins/losses for each round
      - `id` (uuid, primary key)
      - `team_id` (uuid, references teams)
      - `round_id` (uuid, references rounds)
      - `season_id` (uuid, references seasons)
      - `won` (boolean)
      - `created_at` (timestamp)

  2. New Views
    - `team_earnings`: Aggregates team performance and earnings data
      - Shows team details (college, region, seed)
      - Shows owner information
      - Calculates total earnings and net profit
      - Filters by season

  3. Security
    - Enable RLS on team_results table
    - Add policy for public read access
*/

-- Create team_results table
CREATE TABLE IF NOT EXISTS team_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid NOT NULL REFERENCES teams(id),
  round_id uuid NOT NULL REFERENCES rounds(id),
  season_id uuid NOT NULL REFERENCES seasons(id),
  won boolean NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(team_id, round_id, season_id)
);

-- Enable RLS
ALTER TABLE team_results ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Allow public read access to team_results"
  ON team_results
  FOR SELECT
  TO public
  USING (true);

-- Create team_earnings view
CREATE OR REPLACE VIEW team_earnings AS
WITH team_round_results AS (
  SELECT
    tr.team_id,
    tr.season_id,
    SUM(CASE WHEN tr.won THEN r.payout_percentage * s.prize_pool ELSE 0 END) as total_earnings
  FROM team_results tr
  JOIN rounds r ON r.id = tr.round_id
  JOIN seasons s ON s.id = tr.season_id
  GROUP BY tr.team_id, tr.season_id
)
SELECT
  t.id as team_id,
  t.season_id,
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
  COALESCE(trr.total_earnings, 0) as total_earnings,
  COALESCE(trr.total_earnings, 0) - t.purchase_price as net_profit
FROM teams t
LEFT JOIN owners o ON o.id = t.owner_id
JOIN seasons s ON s.id = t.season_id
LEFT JOIN team_round_results trr ON trr.team_id = t.id AND trr.season_id = t.season_id;