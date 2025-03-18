/*
  # Add 2025 Tournament Teams

  1. Purpose
    - Create season record for 2025
    - Insert all 64 teams for the 2025 tournament
    - Teams organized by region (South, East, Midwest, West)
    - All teams start with purchase_price = 0

  2. Details
    - Creates season first with valid prize pool (1)
    - Inserts teams with correct seeding
    - Sets initial prize pool to minimum valid value
*/

-- First, create the 2025 season if it doesn't exist
INSERT INTO seasons (year, name, prize_pool)
SELECT 2025, '2025 NCAA Tournament', 1
WHERE NOT EXISTS (
  SELECT 1 FROM seasons WHERE year = 2025
);

-- Then insert all teams
WITH season AS (
  SELECT id FROM seasons WHERE year = 2025
)
INSERT INTO teams (
  college,
  region,
  overall_seed,
  region_seed,
  season_id,
  purchase_price
)
SELECT
  college,
  region,
  overall_seed,
  region_seed,
  season.id,
  0 -- Initial purchase price
FROM (
  VALUES
    -- South Region
    ('Auburn', 'South', 1, 1),
    ('Michigan State', 'South', 8, 2),
    ('Iowa St', 'South', 9, 3),
    ('Texas A&M', 'South', 16, 4),
    ('Michigan', 'South', 17, 5),
    ('Mississipi', 'South', 24, 6),
    ('Marquette', 'South', 25, 7),
    ('Louisville', 'South', 32, 8),
    ('Creighton', 'South', 33, 9),
    ('New Mexico', 'South', 40, 10),
    ('SDSU', 'South', 41, 11),
    ('UCSD', 'South', 48, 12),
    ('Yale', 'South', 49, 13),
    ('Lipscomb', 'South', 56, 14),
    ('Bryant', 'South', 57, 15),
    ('SFPA', 'South', 64, 16),

    -- East Region
    ('Duke', 'East', 2, 1),
    ('Alabama', 'East', 7, 2),
    ('Wisconsin', 'East', 10, 3),
    ('Arizona', 'East', 15, 4),
    ('Oregon', 'East', 18, 5),
    ('BYU', 'East', 23, 6),
    ('St Marys', 'East', 26, 7),
    ('Mississipi St', 'East', 31, 8),
    ('Baylor', 'East', 34, 9),
    ('Vanderbilt', 'East', 39, 10),
    ('VCU', 'East', 42, 11),
    ('Liberty', 'East', 47, 12),
    ('Akron', 'East', 50, 13),
    ('Montana', 'East', 55, 14),
    ('Robert Morris', 'East', 58, 15),
    ('MSM', 'East', 63, 16),

    -- Midwest Region
    ('Houston', 'Midwest', 3, 1),
    ('Tennessee', 'Midwest', 6, 2),
    ('Kentucky', 'Midwest', 11, 3),
    ('Purdue', 'Midwest', 14, 4),
    ('Clemson', 'Midwest', 19, 5),
    ('Illinois', 'Midwest', 22, 6),
    ('UCLA', 'Midwest', 27, 7),
    ('Gonzaga', 'Midwest', 30, 8),
    ('Georgia', 'Midwest', 35, 9),
    ('Utah St', 'Midwest', 38, 10),
    ('Texas', 'Midwest', 43, 11),
    ('McNeese', 'Midwest', 46, 12),
    ('High Point', 'Midwest', 51, 13),
    ('Troy', 'Midwest', 54, 14),
    ('Wofford', 'Midwest', 59, 15),
    ('SIU Edwardsville', 'Midwest', 62, 16),

    -- West Region
    ('Florida', 'West', 4, 1),
    ('St Johns', 'West', 5, 2),
    ('Texas Tech', 'West', 12, 3),
    ('Maryland', 'West', 13, 4),
    ('Memphis', 'West', 20, 5),
    ('Missouri', 'West', 21, 6),
    ('Kansas', 'West', 28, 7),
    ('UConn', 'West', 29, 8),
    ('Oklahoma', 'West', 36, 9),
    ('Arkansas', 'West', 37, 10),
    ('Drake', 'West', 44, 11),
    ('Colorado St', 'West', 45, 12),
    ('Grand Canyon', 'West', 52, 13),
    ('NC Wilmington', 'West', 53, 14),
    ('Nebraska Omaha', 'West', 60, 15),
    ('Norfolk St', 'West', 61, 16)
) AS t(college, region, overall_seed, region_seed)
CROSS JOIN season;