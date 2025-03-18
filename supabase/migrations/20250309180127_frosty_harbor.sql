/*
  # Add champion and game scores

  1. Changes
    - Add champion_team_id to seasons table (foreign key to teams)
    - Add team1_score and team2_score to games table
    
  2. Security
    - Maintain existing RLS settings
    - Add foreign key constraint for champion_team_id
*/

-- Add champion_team_id to seasons table
ALTER TABLE seasons 
  ADD COLUMN champion_team_id uuid REFERENCES teams(id);

-- Add score columns to games table
ALTER TABLE games 
  ADD COLUMN team1_score integer,
  ADD COLUMN team2_score integer;

-- Add constraint to ensure scores are non-negative
ALTER TABLE games
  ADD CONSTRAINT valid_team1_score CHECK (team1_score >= 0),
  ADD CONSTRAINT valid_team2_score CHECK (team2_score >= 0);