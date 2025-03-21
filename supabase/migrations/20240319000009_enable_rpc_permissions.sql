-- Grant execute permission on the function to the anon role
GRANT EXECUTE ON FUNCTION advance_to_next_round(UUID, UUID, INTEGER, INTEGER) TO anon;

-- Also grant update permissions on games table if not already granted
GRANT UPDATE (winner_id, team1_score, team2_score) ON games TO anon; 