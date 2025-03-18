/*
  # Update 2025 Tournament Teams

  1. Purpose
    - Create owners if they don't exist
    - Update team purchase prices
    - Assign owners to teams
    - Handle grouped teams (13-16 seeds)

  2. Details
    - Creates owners with unique emails
    - Updates team prices removing $ and converting to cents
    - Maps teams to correct owners
    - Handles special cases for grouped seed ranges
*/

-- First, ensure all owners exist
INSERT INTO owners (name, email)
VALUES 
  ('Jake Little', 'jake.little@example.com'),
  ('Parker Kelley', 'parker.kelley@example.com'),
  ('Jace Olsen', 'jace.olsen@example.com'),
  ('Deven Ram', 'deven.ram@example.com'),
  ('Bryce Miller', 'bryce.miller@example.com'),
  ('John Hausle', 'john.hausle@example.com'),
  ('Dylan Ramey', 'dylan.ramey@example.com'),
  ('Davis Waddell', 'davis.waddell@example.com'),
  ('Max Greenberg', 'max.greenberg@example.com'),
  ('Zach Schwartz', 'zach.schwartz@example.com'),
  ('Ryan Ramey', 'ryan.ramey@example.com'),
  ('Dev Sousa', 'dev.sousa@example.com')
ON CONFLICT (email) DO NOTHING;

-- Update teams with prices and owners
DO $$
DECLARE
  v_season_id uuid;
  v_owner_id uuid;
BEGIN
  -- Get the 2025 season ID
  SELECT id INTO v_season_id FROM seasons WHERE year = 2025;

  -- South Region (was called South in original data)
  
  -- Auburn (1)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 30000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Auburn';

  -- Michigan State (2)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Parker Kelley';
  UPDATE teams SET purchase_price = 18000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Michigan State';

  -- Iowa St (3)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jace Olsen';
  UPDATE teams SET purchase_price = 15100, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Iowa St';

  -- Texas A&M (4)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 8700, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Texas A&M';

  -- Michigan (5)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 7300, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Michigan';

  -- Ole Miss/Mississippi (6)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'John Hausle';
  UPDATE teams SET purchase_price = 6100, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Mississipi';

  -- Marquette (7)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dylan Ramey';
  UPDATE teams SET purchase_price = 5800, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Marquette';

  -- Louisville (8)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Davis Waddell';
  UPDATE teams SET purchase_price = 6300, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Louisville';

  -- Creighton (9)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 4100, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Creighton';

  -- New Mexico (10)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 2800, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'New Mexico';

  -- SDSU (11)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Max Greenberg';
  UPDATE teams SET purchase_price = 5400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'SDSU';

  -- UCSD (12)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dev Sousa';
  UPDATE teams SET purchase_price = 4900, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'UCSD';

  -- Yale, Lipscomb, Bryant, SFPA (13-16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id 
  AND college IN ('Yale', 'Lipscomb', 'Bryant', 'SFPA');

  -- West Region
  
  -- Florida (1)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Zach Schwartz';
  UPDATE teams SET purchase_price = 31700, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Florida';

  -- St Johns (2)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Zach Schwartz';
  UPDATE teams SET purchase_price = 18500, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'St Johns';

  -- Texas Tech (3)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dylan Ramey';
  UPDATE teams SET purchase_price = 14100, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Texas Tech';

  -- Maryland (4)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Ryan Ramey';
  UPDATE teams SET purchase_price = 12400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Maryland';

  -- Memphis (5)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jace Olsen';
  UPDATE teams SET purchase_price = 4700, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Memphis';

  -- Missouri (6)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'John Hausle';
  UPDATE teams SET purchase_price = 5800, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Missouri';

  -- Kansas (7)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Max Greenberg';
  UPDATE teams SET purchase_price = 7400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Kansas';

  -- UConn (8)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Ryan Ramey';
  UPDATE teams SET purchase_price = 6100, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'UConn';

  -- Oklahoma (9)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Parker Kelley';
  UPDATE teams SET purchase_price = 2600, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Oklahoma';

  -- Arkansas (10)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Max Greenberg';
  UPDATE teams SET purchase_price = 3600, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Arkansas';

  -- Drake (11)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Ryan Ramey';
  UPDATE teams SET purchase_price = 3200, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Drake';

  -- Colorado St (12)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 3800, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Colorado St';

  -- Grand Canyon, NC Wilmington, Nebraska Omaha, Norfolk St (13-16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 950, owner_id = v_owner_id
  WHERE season_id = v_season_id 
  AND college IN ('Grand Canyon', 'NC Wilmington', 'Nebraska Omaha', 'Norfolk St');

  -- East Region
  
  -- Duke (1)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Parker Kelley';
  UPDATE teams SET purchase_price = 34600, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Duke';

  -- Alabama (2)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Max Greenberg';
  UPDATE teams SET purchase_price = 17300, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Alabama';

  -- Wisconsin (3)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jace Olsen';
  UPDATE teams SET purchase_price = 12400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Wisconsin';

  -- Arizona (4)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Davis Waddell';
  UPDATE teams SET purchase_price = 9900, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Arizona';

  -- Oregon (5)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 5600, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Oregon';

  -- BYU (6)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dylan Ramey';
  UPDATE teams SET purchase_price = 6500, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'BYU';

  -- St Marys (7)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Zach Schwartz';
  UPDATE teams SET purchase_price = 5400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'St Marys';

  -- Mississippi St (8)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 4000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Mississipi St';

  -- Baylor (9)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Parker Kelley';
  UPDATE teams SET purchase_price = 4000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Baylor';

  -- Vanderbilt (10)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 4200, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Vanderbilt';

  -- VCU (11)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jace Olsen';
  UPDATE teams SET purchase_price = 4000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'VCU';

  -- Liberty (12)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Ryan Ramey';
  UPDATE teams SET purchase_price = 3500, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Liberty';

  -- Akron, Montana, Robert Morris, MSM (13-16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dev Sousa';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id 
  AND college IN ('Akron', 'Montana', 'Robert Morris', 'MSM');

  -- Midwest Region
  
  -- Houston (1)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Davis Waddell';
  UPDATE teams SET purchase_price = 23300, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Houston';

  -- Tennessee (2)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'John Hausle';
  UPDATE teams SET purchase_price = 19300, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Tennessee';

  -- Kentucky (3)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 13800, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Kentucky';

  -- Purdue (4)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 9400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Purdue';

  -- Clemson (5)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Davis Waddell';
  UPDATE teams SET purchase_price = 8200, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Clemson';

  -- Illinois (6)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Max Greenberg';
  UPDATE teams SET purchase_price = 7000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Illinois';

  -- UCLA (7)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 5400, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'UCLA';

  -- Gonzaga (8)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Parker Kelley';
  UPDATE teams SET purchase_price = 7800, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Gonzaga';

  -- Georgia (9)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 3500, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Georgia';

  -- Utah St (10)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 3000, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Utah St';

  -- Texas (11)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Parker Kelley';
  UPDATE teams SET purchase_price = 3600, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Texas';

  -- McNeese (12)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'John Hausle';
  UPDATE teams SET purchase_price = 2500, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'McNeese';

  -- High Point, Troy, Wofford, SIUE (13-16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 1225, owner_id = v_owner_id
  WHERE season_id = v_season_id 
  AND college IN ('High Point', 'Troy', 'Wofford', 'SIU Edwardsville');

  -- Update season prize pool to total of all purchase prices
  UPDATE seasons 
  SET prize_pool = (
    SELECT SUM(purchase_price)
    FROM teams
    WHERE season_id = v_season_id
  )
  WHERE id = v_season_id;

END $$;