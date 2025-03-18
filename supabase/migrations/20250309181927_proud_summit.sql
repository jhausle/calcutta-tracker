/*
  # Drop team_earnings view

  1. Changes
    - Drop the team_earnings view as it's no longer needed
    - The view is being replaced by the owner_earnings table for more accurate earnings tracking
*/

DROP VIEW IF EXISTS team_earnings;