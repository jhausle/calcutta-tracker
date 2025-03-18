/*
  # Update 2025 Tournament Teams

  1. Purpose
    - Update team purchase prices
    - Assign owners to teams
    - Handle individual prices for 13-16 seeds

  2. Details
    - Updates team prices removing $ and converting to cents
    - Maps teams to correct owners
    - Handles individual prices for all seeds
*/

DO $$
DECLARE
  v_season_id uuid;
  v_owner_id uuid;
BEGIN
  -- Get the 2025 season ID
  SELECT id INTO v_season_id FROM seasons WHERE year = 2025;

  -- South Region
  
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

  -- Mississippi (6)
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

  -- Yale (13)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Yale';

  -- Lipscomb (14)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Lipscomb';

  -- Bryant (15)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Bryant';

  -- SFPA (16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Bryce Miller';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'SFPA';

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

  -- Grand Canyon (13)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 950, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Grand Canyon';

  -- NC Wilmington (14)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 950, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'NC Wilmington';

  -- Nebraska Omaha (15)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 950, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Nebraska Omaha';

  -- Norfolk St (16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Jake Little';
  UPDATE teams SET purchase_price = 950, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Norfolk St';

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

  -- Akron (13)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dev Sousa';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Akron';

  -- Montana (14)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dev Sousa';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Montana';

  -- Robert Morris (15)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dev Sousa';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Robert Morris';

  -- MSM (16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Dev Sousa';
  UPDATE teams SET purchase_price = 1175, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'MSM';

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

  -- High Point (13)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 1225, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'High Point';

  -- Troy (14)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 1225, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Troy';

  -- Wofford (15)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 1225, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'Wofford';

  -- SIU Edwardsville (16)
  SELECT id INTO v_owner_id FROM owners WHERE name = 'Deven Ram';
  UPDATE teams SET purchase_price = 1225, owner_id = v_owner_id
  WHERE season_id = v_season_id AND college = 'SIU Edwardsville';

  -- Update season prize pool to total of all purchase prices
  UPDATE seasons 
  SET prize_pool = (
    SELECT SUM(purchase_price)
    FROM teams
    WHERE season_id = v_season_id
  )
  WHERE id = v_season_id;

END $$;