/*
  # Add owners and assign them to teams

  1. Data Population
    - Create sample owners with names and email addresses
    - Assign owners to teams in a balanced way
    - Each owner gets a mix of high and low seeds

  2. Owner Distribution
    - Create 8 owners who will each get 8 teams
    - Distribute teams evenly across regions
    - Ensure each owner gets at least one high seed (1-4)
    - Balance the total purchase price across owners
*/

-- First, create some sample owners
INSERT INTO owners (name, email) VALUES
  ('John Smith', 'john.smith@example.com'),
  ('Sarah Johnson', 'sarah.j@example.com'),
  ('Michael Brown', 'mbrown@example.com'),
  ('Emily Davis', 'emily.davis@example.com'),
  ('David Wilson', 'dwilson@example.com'),
  ('Jessica Taylor', 'jtaylor@example.com'),
  ('Robert Martinez', 'rmartinez@example.com'),
  ('Lisa Anderson', 'landerson@example.com');

DO $$
DECLARE
  v_season_id uuid;
  v_owner_ids uuid[];
BEGIN
  -- Get the season ID for 2024
  SELECT id INTO v_season_id FROM seasons WHERE year = 2024;
  
  -- Get all owner IDs in an array, ordered by ID to ensure consistent ordering
  SELECT array_agg(id ORDER BY id) INTO v_owner_ids FROM owners;

  -- Update West region teams
  UPDATE teams 
  SET owner_id = v_owner_ids[1]
  WHERE season_id = v_season_id AND region = 'West' AND region_seed IN (1, 8, 9, 16);

  UPDATE teams 
  SET owner_id = v_owner_ids[2]
  WHERE season_id = v_season_id AND region = 'West' AND region_seed IN (2, 7, 10, 15);

  UPDATE teams 
  SET owner_id = v_owner_ids[3]
  WHERE season_id = v_season_id AND region = 'West' AND region_seed IN (3, 6, 11, 14);

  UPDATE teams 
  SET owner_id = v_owner_ids[4]
  WHERE season_id = v_season_id AND region = 'West' AND region_seed IN (4, 5, 12, 13);

  -- Update East region teams
  UPDATE teams 
  SET owner_id = v_owner_ids[5]
  WHERE season_id = v_season_id AND region = 'East' AND region_seed IN (1, 8, 9, 16);

  UPDATE teams 
  SET owner_id = v_owner_ids[6]
  WHERE season_id = v_season_id AND region = 'East' AND region_seed IN (2, 7, 10, 15);

  UPDATE teams 
  SET owner_id = v_owner_ids[7]
  WHERE season_id = v_season_id AND region = 'East' AND region_seed IN (3, 6, 11, 14);

  UPDATE teams 
  SET owner_id = v_owner_ids[8]
  WHERE season_id = v_season_id AND region = 'East' AND region_seed IN (4, 5, 12, 13);

  -- Update South region teams
  UPDATE teams 
  SET owner_id = v_owner_ids[1]
  WHERE season_id = v_season_id AND region = 'South' AND region_seed IN (4, 5, 12, 13);

  UPDATE teams 
  SET owner_id = v_owner_ids[2]
  WHERE season_id = v_season_id AND region = 'South' AND region_seed IN (3, 6, 11, 14);

  UPDATE teams 
  SET owner_id = v_owner_ids[3]
  WHERE season_id = v_season_id AND region = 'South' AND region_seed IN (2, 7, 10, 15);

  UPDATE teams 
  SET owner_id = v_owner_ids[4]
  WHERE season_id = v_season_id AND region = 'South' AND region_seed IN (1, 8, 9, 16);

  -- Update Midwest region teams
  UPDATE teams 
  SET owner_id = v_owner_ids[5]
  WHERE season_id = v_season_id AND region = 'Midwest' AND region_seed IN (4, 5, 12, 13);

  UPDATE teams 
  SET owner_id = v_owner_ids[6]
  WHERE season_id = v_season_id AND region = 'Midwest' AND region_seed IN (3, 6, 11, 14);

  UPDATE teams 
  SET owner_id = v_owner_ids[7]
  WHERE season_id = v_season_id AND region = 'Midwest' AND region_seed IN (2, 7, 10, 15);

  UPDATE teams 
  SET owner_id = v_owner_ids[8]
  WHERE season_id = v_season_id AND region = 'Midwest' AND region_seed IN (1, 8, 9, 16);
END $$;