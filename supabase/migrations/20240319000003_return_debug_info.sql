DROP FUNCTION IF EXISTS advance_to_next_round;

CREATE OR REPLACE FUNCTION advance_to_next_round(
  game_id UUID,
  winner_team_id UUID,
  team1_score INTEGER DEFAULT NULL,
  team2_score INTEGER DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
  next_game_id UUID;
  current_game_number INTEGER;
  next_game_number INTEGER;
  current_round INTEGER;
  winner_region TEXT;
  should_be_team1 BOOLEAN;
  debug_info jsonb;
BEGIN
  -- [Previous code remains the same until debug section]

  debug_info := jsonb_build_object(
    'current_game', current_game_number,
    'current_round', current_round,
    'winner_region', winner_region,
    'next_game_number', next_game_number,
    'should_be_team1', should_be_team1,
    'next_game_found', next_game_id IS NOT NULL
  );

  -- [Rest of the function remains the same]

  RETURN debug_info;
END;
$$ LANGUAGE plpgsql; 