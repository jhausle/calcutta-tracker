/*
  # Add game progression tracking

  1. New Tables
    - `game_progression`
      - `id` (uuid, primary key)
      - `round_name` (text) - Name of the current round
      - `match_number` (integer) - Game number in current round
      - `next_round_name` (text) - Name of the next round
      - `next_match_number` (integer) - Game number in next round
      - `team_position` (integer) - Position in next round's game (1 or 2)

  2. Notes
    - This table defines how winners progress through the tournament
    - Each record maps a game to its next game in the following round
    - For the championship game, next values are null
*/

-- Create game progression table
CREATE TABLE IF NOT EXISTS game_progression (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  round_name text NOT NULL,
  match_number integer NOT NULL,
  next_round_name text,
  next_match_number integer,
  team_position integer,
  created_at timestamptz DEFAULT now(),
  
  -- Ensure team position is either 1 or 2
  CONSTRAINT valid_team_position CHECK (
    team_position IS NULL OR 
    (team_position >= 1 AND team_position <= 2)
  ),
  
  -- Ensure match numbers are positive
  CONSTRAINT valid_match_number CHECK (match_number > 0),
  CONSTRAINT valid_next_match_number CHECK (
    next_match_number IS NULL OR next_match_number > 0
  )
);

-- Enable RLS
ALTER TABLE game_progression ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access to game_progression"
  ON game_progression
  FOR SELECT
  TO public
  USING (true);

-- Insert progression data for Round of 64
INSERT INTO game_progression (round_name, match_number, next_round_name, next_match_number, team_position) VALUES
-- First set of Round of 64 games (1-16)
('Round of 64', 1, 'Round of 32', 1, 1),
('Round of 64', 2, 'Round of 32', 1, 2),
('Round of 64', 3, 'Round of 32', 2, 1),
('Round of 64', 4, 'Round of 32', 2, 2),
('Round of 64', 5, 'Round of 32', 3, 1),
('Round of 64', 6, 'Round of 32', 3, 2),
('Round of 64', 7, 'Round of 32', 4, 1),
('Round of 64', 8, 'Round of 32', 4, 2),
('Round of 64', 9, 'Round of 32', 5, 1),
('Round of 64', 10, 'Round of 32', 5, 2),
('Round of 64', 11, 'Round of 32', 6, 1),
('Round of 64', 12, 'Round of 32', 6, 2),
('Round of 64', 13, 'Round of 32', 7, 1),
('Round of 64', 14, 'Round of 32', 7, 2),
('Round of 64', 15, 'Round of 32', 8, 1),
('Round of 64', 16, 'Round of 32', 8, 2),
-- Second set of Round of 64 games (17-32)
('Round of 64', 17, 'Round of 32', 9, 1),
('Round of 64', 18, 'Round of 32', 9, 2),
('Round of 64', 19, 'Round of 32', 10, 1),
('Round of 64', 20, 'Round of 32', 10, 2),
('Round of 64', 21, 'Round of 32', 11, 1),
('Round of 64', 22, 'Round of 32', 11, 2),
('Round of 64', 23, 'Round of 32', 12, 1),
('Round of 64', 24, 'Round of 32', 12, 2),
('Round of 64', 25, 'Round of 32', 13, 1),
('Round of 64', 26, 'Round of 32', 13, 2),
('Round of 64', 27, 'Round of 32', 14, 1),
('Round of 64', 28, 'Round of 32', 14, 2),
('Round of 64', 29, 'Round of 32', 15, 1),
('Round of 64', 30, 'Round of 32', 15, 2),
('Round of 64', 31, 'Round of 32', 16, 1),
('Round of 64', 32, 'Round of 32', 16, 2);

-- Insert progression data for Round of 32
INSERT INTO game_progression (round_name, match_number, next_round_name, next_match_number, team_position) VALUES
('Round of 32', 1, 'Sweet 16', 1, 1),
('Round of 32', 2, 'Sweet 16', 1, 2),
('Round of 32', 3, 'Sweet 16', 2, 1),
('Round of 32', 4, 'Sweet 16', 2, 2),
('Round of 32', 5, 'Sweet 16', 3, 1),
('Round of 32', 6, 'Sweet 16', 3, 2),
('Round of 32', 7, 'Sweet 16', 4, 1),
('Round of 32', 8, 'Sweet 16', 4, 2),
('Round of 32', 9, 'Sweet 16', 5, 1),
('Round of 32', 10, 'Sweet 16', 5, 2),
('Round of 32', 11, 'Sweet 16', 6, 1),
('Round of 32', 12, 'Sweet 16', 6, 2),
('Round of 32', 13, 'Sweet 16', 7, 1),
('Round of 32', 14, 'Sweet 16', 7, 2),
('Round of 32', 15, 'Sweet 16', 8, 1),
('Round of 32', 16, 'Sweet 16', 8, 2);

-- Insert progression data for Sweet 16
INSERT INTO game_progression (round_name, match_number, next_round_name, next_match_number, team_position) VALUES
('Sweet 16', 1, 'Elite Eight', 1, 1),
('Sweet 16', 2, 'Elite Eight', 1, 2),
('Sweet 16', 3, 'Elite Eight', 2, 1),
('Sweet 16', 4, 'Elite Eight', 2, 2),
('Sweet 16', 5, 'Elite Eight', 3, 1),
('Sweet 16', 6, 'Elite Eight', 3, 2),
('Sweet 16', 7, 'Elite Eight', 4, 1),
('Sweet 16', 8, 'Elite Eight', 4, 2);

-- Insert progression data for Elite Eight
INSERT INTO game_progression (round_name, match_number, next_round_name, next_match_number, team_position) VALUES
('Elite Eight', 1, 'Final Four', 1, 1),
('Elite Eight', 2, 'Final Four', 1, 2),
('Elite Eight', 3, 'Final Four', 2, 1),
('Elite Eight', 4, 'Final Four', 2, 2);

-- Insert progression data for Final Four
INSERT INTO game_progression (round_name, match_number, next_round_name, next_match_number, team_position) VALUES
('Final Four', 1, 'Championship', 1, 1),
('Final Four', 2, 'Championship', 1, 2);

-- Insert progression data for Championship (no next game)
INSERT INTO game_progression (round_name, match_number, next_round_name, next_match_number, team_position) VALUES
('Championship', 1, NULL, NULL, NULL);