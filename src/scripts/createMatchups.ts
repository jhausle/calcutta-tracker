import { supabase } from '../lib/supabase';

async function createFirstRoundGames() {
  try {
    // Get the current season
    const { data: season, error: seasonError } = await supabase
      .from('seasons')
      .select('id')
      .eq('year', 2024)
      .single();

    if (seasonError) throw seasonError;
    if (!season) throw new Error('Season not found');

    // Get the Round of 64
    const { data: round, error: roundError } = await supabase
      .from('rounds')
      .select('id')
      .eq('name', 'Round of 64')
      .single();

    if (roundError) throw roundError;
    if (!round) throw new Error('Round not found');

    // Get all teams for the current season
    const { data: teams, error: teamsError } = await supabase
      .from('teams')
      .select('id, college, region, region_seed')
      .eq('season_id', season.id)
      .order('region')
      .order('region_seed');

    if (teamsError) throw teamsError;
    if (!teams) throw new Error('No teams found');

    // Group teams by region
    const teamsByRegion = teams.reduce((acc, team) => {
      if (!acc[team.region]) {
        acc[team.region] = [];
      }
      acc[team.region].push(team);
      return acc;
    }, {} as Record<string, typeof teams>);

    // Create games for each region
    const games = [];
    for (const region of ['West', 'East', 'South', 'Midwest']) {
      const regionTeams = teamsByRegion[region];
      if (!regionTeams) continue;

      // Find teams by seed
      const seed1 = regionTeams.find(t => t.region_seed === 1);
      const seed2 = regionTeams.find(t => t.region_seed === 2);
      const seed4 = regionTeams.find(t => t.region_seed === 4);
      const seed6 = regionTeams.find(t => t.region_seed === 6);

      if (!seed1 || !seed2 || !seed4 || !seed6) {
        console.error(`Missing required seeds for region ${region}`);
        continue;
      }

      // Create games: 1 vs 6, 2 vs 4
      games.push(
        {
          round_id: round.id,
          season_id: season.id,
          team1_id: seed1.id,
          team2_id: seed6.id,
          game_date: new Date().toISOString()
        },
        {
          round_id: round.id,
          season_id: season.id,
          team1_id: seed2.id,
          team2_id: seed4.id,
          game_date: new Date().toISOString()
        }
      );
    }

    // Insert all games
    const { error: insertError } = await supabase
      .from('games')
      .insert(games);

    if (insertError) throw insertError;

    console.log('Successfully created first round games');
  } catch (error) {
    console.error('Error creating games:', error);
  }
}

createFirstRoundGames();