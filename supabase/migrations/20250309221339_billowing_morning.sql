/*
  # Remove team_results table and update tournament management

  1. Changes
    - Drop team_results table as it's redundant with games.winner_id
    - Remove foreign key constraints referencing team_results
    - Update tournament management to use games table directly

  2. Technical Details
    - Safe removal of table and constraints
    - No data loss as all information is in games table
*/

-- Drop the team_results table and its dependencies
DROP TABLE IF EXISTS team_results;