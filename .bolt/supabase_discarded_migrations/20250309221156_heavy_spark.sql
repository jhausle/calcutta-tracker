/*
  # Add RLS policies for team_results table

  1. Security Changes
    - Enable RLS on team_results table if not already enabled
    - Add policies if they don't exist:
      - Public read access to team results
      - Admin write access for managing team results
*/

-- Enable RLS (if not already enabled)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'team_results' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE team_results ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Add public read access policy if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'team_results' 
    AND policyname = 'Allow public read access to team_results'
  ) THEN
    CREATE POLICY "Allow public read access to team_results"
    ON team_results
    FOR SELECT
    TO public
    USING (true);
  END IF;
END $$;

-- Add authenticated users management policy if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'team_results' 
    AND policyname = 'Allow authenticated users to manage team results'
  ) THEN
    CREATE POLICY "Allow authenticated users to manage team results"
    ON team_results
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);
  END IF;
END $$;