/*
  # Update 2024 season prize pool

  1. Changes
    - Updates the prize pool for the 2024 season
    - Calculates total from team purchase prices
    - Ensures data consistency

  2. Details
    - Sums up all purchase prices from teams table
    - Updates the corresponding season record
    - Uses a safe update approach with data validation
*/

DO $$ 
DECLARE
  total_purchase_price INTEGER;
  target_season_id UUID;
BEGIN
  -- Get the season ID for 2024
  SELECT id INTO target_season_id
  FROM seasons
  WHERE year = 2024;

  IF target_season_id IS NULL THEN
    RAISE EXCEPTION 'Season 2024 not found';
  END IF;

  -- Calculate total purchase price
  SELECT COALESCE(SUM(purchase_price), 0)
  INTO total_purchase_price
  FROM teams
  WHERE season_id = target_season_id;

  -- Update the season's prize pool
  UPDATE seasons
  SET prize_pool = total_purchase_price
  WHERE id = target_season_id;

  RAISE NOTICE 'Updated 2024 season prize pool to %', total_purchase_price;
END $$;