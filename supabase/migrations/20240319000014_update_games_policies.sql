-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON games;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON games;
DROP POLICY IF EXISTS "Enable update for anon users" ON games;

-- Create read policy
CREATE POLICY "Enable read access for all users" 
ON games FOR SELECT 
TO public 
USING (true);

-- Create update policy
CREATE POLICY "Enable update for all users" 
ON games FOR UPDATE 
TO public 
USING (true)  -- Allow reading any row
WITH CHECK (true);  -- Allow updating any row

-- Make sure RLS is enabled
ALTER TABLE games ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT SELECT, UPDATE ON games TO anon;
GRANT SELECT, UPDATE ON games TO authenticated; 