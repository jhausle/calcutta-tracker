/*
  # Add round number to rounds table

  1. Changes
    - Add round_number column to rounds table
    - Update existing rounds with their corresponding numbers
    - Add check constraint to ensure valid round numbers (1-6)

  2. Column Details
    - round_number: integer
      - Round of 64 = 1
      - Round of 32 = 2
      - Sweet 16 = 3
      - Elite 8 = 4
      - Final Four = 5
      - Championship = 6

  3. Constraints
    - round_number must be between 1 and 6
*/

-- Add round_number column
ALTER TABLE rounds 
ADD COLUMN round_number integer;

-- Update existing rounds with their numbers
DO $$
BEGIN
  -- Round of 64
  UPDATE rounds SET round_number = 1 WHERE name = 'Round of 64';
  
  -- Round of 32
  UPDATE rounds SET round_number = 2 WHERE name = 'Round of 32';
  
  -- Sweet 16
  UPDATE rounds SET round_number = 3 WHERE name = 'Sweet 16';
  
  -- Elite 8
  UPDATE rounds SET round_number = 4 WHERE name = 'Elite 8';
  
  -- Final Four
  UPDATE rounds SET round_number = 5 WHERE name = 'Final Four';
  
  -- Championship
  UPDATE rounds SET round_number = 6 WHERE name = 'Championship';
END $$;

-- Make round_number NOT NULL after setting values
ALTER TABLE rounds 
ALTER COLUMN round_number SET NOT NULL;

-- Add check constraint
ALTER TABLE rounds
ADD CONSTRAINT valid_round_number CHECK (round_number BETWEEN 1 AND 6);