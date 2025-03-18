/*
  # Fix Purchase Prices

  1. Purpose
    - Divide all purchase prices by 100 to correct the values
    - Update season prize pool to match new total
    
  2. Details
    - Updates all teams in the 2025 season
    - Maintains data integrity with transaction
    - Updates season prize pool to match new total
*/

DO $$
DECLARE
  v_season_id uuid;
BEGIN
  -- Get the 2025 season ID
  SELECT id INTO v_season_id 
  FROM seasons 
  WHERE year = 2025;

  -- Update all team purchase prices
  UPDATE teams 
  SET purchase_price = purchase_price / 100
  WHERE season_id = v_season_id;

  -- Update season prize pool to match new total
  UPDATE seasons 
  SET prize_pool = (
    SELECT SUM(purchase_price)
    FROM teams
    WHERE season_id = v_season_id
  )
  WHERE id = v_season_id;
END $$;