/*
  # Populate teams table with 2024 tournament teams

  1. Data Population
    - Insert all 64 teams from the 2024 NCAA Tournament
    - Teams are organized by region (West, East, South, Midwest)
    - Each team includes:
      - College name
      - Region
      - Overall seed (1-64)
      - Region seed (1-16)
      - Purchase price (based on seeding)

  2. Purchase Price Logic
    - Higher seeds cost more as they have better chances
    - 1 seeds: $10,000
    - 2 seeds: $8,000
    - 3-4 seeds: $6,000
    - 5-8 seeds: $4,000
    - 9-12 seeds: $2,000
    - 13-16 seeds: $1,000
*/

-- First, get the 2024 season ID
DO $$
DECLARE
  v_season_id uuid;
BEGIN
  SELECT id INTO v_season_id FROM seasons WHERE year = 2024;

  -- West Region
  INSERT INTO teams (college, region, overall_seed, region_seed, season_id, purchase_price) VALUES
    ('Houston', 'West', 1, 1, v_season_id, 10000),
    ('Marquette', 'West', 8, 2, v_season_id, 8000),
    ('Creighton', 'West', 9, 3, v_season_id, 6000),
    ('Kansas', 'West', 16, 4, v_season_id, 6000),
    ('Wisconsin', 'West', 17, 5, v_season_id, 4000),
    ('South Carolina', 'West', 24, 6, v_season_id, 4000),
    ('Florida', 'West', 25, 7, v_season_id, 4000),
    ('Baylor', 'West', 32, 8, v_season_id, 4000),
    ('Texas Tech', 'West', 33, 9, v_season_id, 2000),
    ('Nevada', 'West', 40, 10, v_season_id, 2000),
    ('New Mexico', 'West', 41, 11, v_season_id, 2000),
    ('Grand Canyon', 'West', 48, 12, v_season_id, 2000),
    ('Vermont', 'West', 49, 13, v_season_id, 1000),
    ('Oakland', 'West', 56, 14, v_season_id, 1000),
    ('Western Kentucky', 'West', 57, 15, v_season_id, 1000),
    ('Longwood', 'West', 64, 16, v_season_id, 1000);

  -- East Region
  INSERT INTO teams (college, region, overall_seed, region_seed, season_id, purchase_price) VALUES
    ('UConn', 'East', 2, 1, v_season_id, 10000),
    ('Iowa State', 'East', 7, 2, v_season_id, 8000),
    ('Illinois', 'East', 10, 3, v_season_id, 6000),
    ('Auburn', 'East', 15, 4, v_season_id, 6000),
    ('San Diego State', 'East', 18, 5, v_season_id, 4000),
    ('BYU', 'East', 23, 6, v_season_id, 4000),
    ('Washington State', 'East', 26, 7, v_season_id, 4000),
    ('Northwestern', 'East', 31, 8, v_season_id, 4000),
    ('Memphis', 'East', 34, 9, v_season_id, 2000),
    ('Drake', 'East', 39, 10, v_season_id, 2000),
    ('NC State', 'East', 42, 11, v_season_id, 2000),
    ('UAB', 'East', 47, 12, v_season_id, 2000),
    ('Yale', 'East', 50, 13, v_season_id, 1000),
    ('Morehead State', 'East', 55, 14, v_season_id, 1000),
    ('South Dakota State', 'East', 58, 15, v_season_id, 1000),
    ('Stetson', 'East', 63, 16, v_season_id, 1000);

  -- South Region
  INSERT INTO teams (college, region, overall_seed, region_seed, season_id, purchase_price) VALUES
    ('Purdue', 'South', 3, 1, v_season_id, 10000),
    ('Arizona', 'South', 6, 2, v_season_id, 8000),
    ('Kentucky', 'South', 11, 3, v_season_id, 6000),
    ('Duke', 'South', 14, 4, v_season_id, 6000),
    ('Alabama', 'South', 19, 5, v_season_id, 4000),
    ('Clemson', 'South', 22, 6, v_season_id, 4000),
    ('Dayton', 'South', 27, 7, v_season_id, 4000),
    ('Mississippi State', 'South', 30, 8, v_season_id, 4000),
    ('Texas A&M', 'South', 35, 9, v_season_id, 2000),
    ('Virginia', 'South', 38, 10, v_season_id, 2000),
    ('Oregon', 'South', 43, 11, v_season_id, 2000),
    ('McNeese', 'South', 46, 12, v_season_id, 2000),
    ('Samford', 'South', 51, 13, v_season_id, 1000),
    ('Akron', 'South', 54, 14, v_season_id, 1000),
    ('Saint Peters', 'South', 59, 15, v_season_id, 1000),
    ('Grambling', 'South', 62, 16, v_season_id, 1000);

  -- Midwest Region
  INSERT INTO teams (college, region, overall_seed, region_seed, season_id, purchase_price) VALUES
    ('North Carolina', 'Midwest', 4, 1, v_season_id, 10000),
    ('Tennessee', 'Midwest', 5, 2, v_season_id, 8000),
    ('Baylor', 'Midwest', 12, 3, v_season_id, 6000),
    ('Kansas', 'Midwest', 13, 4, v_season_id, 6000),
    ('Saint Marys', 'Midwest', 20, 5, v_season_id, 4000),
    ('Texas', 'Midwest', 21, 6, v_season_id, 4000),
    ('Gonzaga', 'Midwest', 28, 7, v_season_id, 4000),
    ('Utah State', 'Midwest', 29, 8, v_season_id, 4000),
    ('TCU', 'Midwest', 36, 9, v_season_id, 2000),
    ('Colorado', 'Midwest', 37, 10, v_season_id, 2000),
    ('Michigan State', 'Midwest', 44, 11, v_season_id, 2000),
    ('James Madison', 'Midwest', 45, 12, v_season_id, 2000),
    ('Charleston', 'Midwest', 52, 13, v_season_id, 1000),
    ('Colgate', 'Midwest', 53, 14, v_season_id, 1000),
    ('Eastern Washington', 'Midwest', 60, 15, v_season_id, 1000),
    ('Howard', 'Midwest', 61, 16, v_season_id, 1000);
END $$;