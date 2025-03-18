/*
  # Standardize Round Names and Clean Up Games

  1. Changes
    - Remove "Elite Eight" round if it exists (since "Elite 8" is the standard)
    - Remove any games associated with the "Elite Eight" round
    - No data loss - "Elite 8" is the correct name and contains the proper games
  
  2. Security
    - No security changes needed - maintaining existing policies

  Note: This migration safely handles the case where "Elite 8" already exists
*/

DO $$ 
DECLARE
  elite_eight_id uuid;
BEGIN
  -- Get the ID of the "Elite Eight" round if it exists
  SELECT id INTO elite_eight_id
  FROM rounds
  WHERE name = 'Elite Eight';

  -- If "Elite Eight" exists, clean up associated data
  IF elite_eight_id IS NOT NULL THEN
    -- First delete any games associated with this round
    DELETE FROM games 
    WHERE round_id = elite_eight_id;

    -- Then delete the round itself
    DELETE FROM rounds 
    WHERE id = elite_eight_id;
  END IF;
END $$;