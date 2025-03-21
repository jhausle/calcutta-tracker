import React, { useState, useEffect } from 'react';
import { Trophy, AlertCircle, Plus } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface Game {
  id: string;
  round: {
    id: string;
    name: string;
  };
  team1: {
    id: string;
    college: string;
    region: string;
    region_seed: number;
  } | null;
  team2: {
    id: string;
    college: string;
    region: string;
    region_seed: number;
  } | null;
  winner_id: string | null;
  game_date: string | null;
  game_number: number | null;
}

interface Team {
  id: string;
  college: string;
  region: string;
  region_seed: number;
}

interface Season {
  id: string;
  year: number;
  name: string;
}

// Update the Supabase response type
interface SupabaseGameResponse {
  id: string;
  round_id: string;
  team1: {
    id: string;
    college: string;
    region: string;
    region_seed: number;
  } | null;
  team2: {
    id: string;
    college: string;
    region: string;
    region_seed: number;
  } | null;
  winner_id: string | null;
  game_date: string | null;
  game_number: number | null;
}

function TournamentManagement() {
  const [rounds, setRounds] = useState<{ id: string; name: string; }[]>([]);
  const [selectedRound, setSelectedRound] = useState<string>('');
  const [games, setGames] = useState<Game[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [seasonId, setSeasonId] = useState<string | null>(null);
  const [showAddGame, setShowAddGame] = useState(false);
  const [availableTeams, setAvailableTeams] = useState<Team[]>([]);
  const [selectedTeam1, setSelectedTeam1] = useState<string>('');
  const [selectedTeam2, setSelectedTeam2] = useState<string>('');
  const [gameDate, setGameDate] = useState<string>('');
  const [seasons, setSeasons] = useState<Season[]>([]);
  const [selectedYear, setSelectedYear] = useState<number>(new Date().getFullYear());

  useEffect(() => {
    const fetchSeasons = async () => {
      try {
        const { data, error: seasonsError } = await supabase
          .from('seasons')
          .select('id, year, name')
          .order('year', { ascending: false });

        if (seasonsError) throw seasonsError;
        setSeasons(data || []);
      } catch (err) {
        console.error('Error fetching seasons:', err);
        setError('Failed to load seasons');
      }
    };

    fetchSeasons();
  }, []);

  useEffect(() => {
    const fetchSeasonId = async () => {
      try {
        const { data, error: seasonError } = await supabase
          .from('seasons')
          .select('id')
          .eq('year', selectedYear)
          .single();

        if (seasonError) throw seasonError;
        if (!data?.id) throw new Error('No season found for selected year');
        
        setSeasonId(data.id);
      } catch (err) {
        console.error('Error fetching season:', err);
        setError('Failed to load selected season');
      }
    };

    if (selectedYear) {
      fetchSeasonId();
    }
  }, [selectedYear]);

  useEffect(() => {
    const fetchRounds = async () => {
      try {
        const { data, error: roundsError } = await supabase
          .from('rounds')
          .select('*')
          .order('round_number');

        if (roundsError) throw roundsError;
        setRounds(data || []);
        if (data?.[0]) {
          setSelectedRound(data[0].id);
        }
      } catch (err) {
        console.error('Error fetching rounds:', err);
        setError('Failed to load tournament rounds');
      }
    };

    fetchRounds();
  }, []);

  useEffect(() => {
    const fetchGames = async () => {
      if (!selectedRound || !seasonId) return;

      try {
        setLoading(true);
        
        const { data: gamesData, error: gamesError } = await supabase
          .from('games')
          .select(`
            id,
            round_id,
            team1:team1_id (
              id,
              college,
              region,
              region_seed
            ),
            team2:team2_id (
              id,
              college,
              region,
              region_seed
            ),
            winner_id,
            game_date,
            game_number
          `)
          .eq('round_id', selectedRound)
          .eq('season_id', seasonId)
          .order('game_number');

        if (gamesError) throw gamesError;

        const transformedGames: Game[] = ((gamesData || []) as unknown as SupabaseGameResponse[]).map(game => ({
          id: game.id,
          round: {
            id: selectedRound,
            name: rounds.find(r => r.id === selectedRound)?.name || ''
          },
          team1: game.team1 ? {
            id: game.team1.id,
            college: game.team1.college,
            region: game.team1.region,
            region_seed: game.team1.region_seed
          } : null,
          team2: game.team2 ? {
            id: game.team2.id,
            college: game.team2.college,
            region: game.team2.region,
            region_seed: game.team2.region_seed
          } : null,
          winner_id: game.winner_id,
          game_date: game.game_date,
          game_number: game.game_number
        }));

        setGames(transformedGames);

        // Fetch available teams that aren't in any game for this round
        const { data: teams, error: teamsError } = await supabase
          .from('teams')
          .select('id, college, region, region_seed')
          .eq('season_id', seasonId)
          .order('region')
          .order('region_seed');

        if (teamsError) throw teamsError;

        const usedTeamIds = new Set(transformedGames.flatMap(m => [
          m.team1?.id,
          m.team2?.id
        ].filter(Boolean)));
        
        setAvailableTeams((teams || []).filter(team => !usedTeamIds.has(team.id)));

        setError(null);
      } catch (err) {
        console.error('Error fetching games:', err);
        setError('Failed to load games');
      } finally {
        setLoading(false);
      }
    };

    fetchGames();
  }, [selectedRound, rounds, seasonId]);

  const handleWinnerSelection = async (game: Game, winnerId: string) => {
    if (!seasonId || !game.round.id) return;

    try {
      setSaving(true);
      
      console.log('Attempting update with:', {
        game_id: game.id,
        winner_team_id: winnerId
      });

      // First verify we can read the game
      const { data: verifyData, error: verifyError } = await supabase
        .from('games')
        .select('*')
        .eq('id', game.id)
        .single();

      console.log('Verify read:', { data: verifyData, error: verifyError });

      if (verifyError) {
        throw new Error(`Verify failed: ${verifyError.message}`);
      }

      // Try direct update with more explicit error handling
      const { data: updateData, error: updateError } = await supabase
        .from('games')
        .update({ 
          winner_id: winnerId
        })
        .eq('id', game.id)
        .select()
        .single();

      console.log('Update response:', { data: updateData, error: updateError });

      if (updateError) {
        console.error('Error details:', updateError);
        throw updateError;
      }

      if (!updateData) {
        throw new Error('Update succeeded but no data returned');
      }

      // Advance the winner to the next round
      const { data: advanceData, error: advanceError } = await supabase
        .rpc('advance_winner', {
          game_id: game.id,
          winner_team_id: winnerId
        });

      console.log('Advance response:', { data: advanceData, error: advanceError });

      if (advanceError) {
        console.error('Advance error:', advanceError);
        throw advanceError;
      }

      // Refresh the games list to show any new games created
      fetchGames();

      setError(null);
    } catch (err) {
      console.error('Error updating winner:', err);
      setError('Failed to update game result');
    } finally {
      setSaving(false);
    }
  };

  const handleAddGame = async () => {
    if (!selectedRound || !seasonId || !selectedTeam1 || !selectedTeam2) return;

    try {
      setSaving(true);

      // Get the next available game number
      const maxGameNumber = Math.max(...games.map(g => g.game_number || 0), 0);
      const nextGameNumber = maxGameNumber + 1;

      const { error: gameError } = await supabase
        .from('games')
        .insert({
          round_id: selectedRound,
          season_id: seasonId,
          team1_id: selectedTeam1,
          team2_id: selectedTeam2,
          game_date: gameDate || null,
          game_number: nextGameNumber
        });

      if (gameError) throw gameError;

      setSelectedTeam1('');
      setSelectedTeam2('');
      setGameDate('');
      setShowAddGame(false);
      
      // Refresh the games list
      fetchGames();

      setError(null);
    } catch (err) {
      console.error('Error adding game:', err);
      setError('Failed to create game');
    } finally {
      setSaving(false);
    }
  };

  const fetchGames = async () => {
    if (!selectedRound || !seasonId) return;

    try {
      const { data: gamesData, error: gamesError } = await supabase
        .from('games')
        .select(`
          id,
          round_id,
          team1:team1_id (
            id,
            college,
            region,
            region_seed
          ),
          team2:team2_id (
            id,
            college,
            region,
            region_seed
          ),
          winner_id,
          game_date,
          game_number
        `)
        .eq('round_id', selectedRound)
        .eq('season_id', seasonId)
        .order('game_number');

      if (gamesError) throw gamesError;

      const transformedGames: Game[] = ((gamesData || []) as unknown as SupabaseGameResponse[]).map(game => ({
        id: game.id,
        round: {
          id: selectedRound,
          name: rounds.find(r => r.id === selectedRound)?.name || ''
        },
        team1: game.team1 ? {
          id: game.team1.id,
          college: game.team1.college,
          region: game.team1.region,
          region_seed: game.team1.region_seed
        } : null,
        team2: game.team2 ? {
          id: game.team2.id,
          college: game.team2.college,
          region: game.team2.region,
          region_seed: game.team2.region_seed
        } : null,
        winner_id: game.winner_id,
        game_date: game.game_date,
        game_number: game.game_number
      }));

      setGames(transformedGames);
    } catch (err) {
      console.error('Error refreshing games:', err);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-gray-900">Tournament Management</h1>
        <div className="flex items-center space-x-4">
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value, 10))}
            className="px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            {seasons.map((season) => (
              <option key={season.id} value={season.year}>
                {season.year} Tournament
              </option>
            ))}
          </select>
          <select
            value={selectedRound}
            onChange={(e) => setSelectedRound(e.target.value)}
            className="px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            {rounds.map((round) => (
              <option key={round.id} value={round.id}>
                {round.name}
              </option>
            ))}
          </select>
          <button
            onClick={() => setShowAddGame(true)}
            className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
          >
            <Plus size={20} />
            <span>Add Game</span>
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative flex items-center" role="alert">
          <AlertCircle className="mr-2" size={20} />
          <span className="block sm:inline">{error}</span>
        </div>
      )}

      {showAddGame && (
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Add New Game</h2>
          <div className="grid grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Team 1</label>
              <select
                value={selectedTeam1}
                onChange={(e) => setSelectedTeam1(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Team 1</option>
                {availableTeams.map((team) => (
                  <option key={team.id} value={team.id}>
                    {team.region} #{team.region_seed} - {team.college}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Team 2</label>
              <select
                value={selectedTeam2}
                onChange={(e) => setSelectedTeam2(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Team 2</option>
                {availableTeams
                  .filter(team => team.id !== selectedTeam1)
                  .map((team) => (
                    <option key={team.id} value={team.id}>
                      {team.region} #{team.region_seed} - {team.college}
                    </option>
                  ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Game Date</label>
              <input
                type="datetime-local"
                value={gameDate}
                onChange={(e) => setGameDate(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <div className="mt-6 flex justify-end space-x-3">
            <button
              onClick={() => setShowAddGame(false)}
              className="px-4 py-2 border rounded-md hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleAddGame}
              disabled={!selectedTeam1 || !selectedTeam2 || saving}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50"
            >
              Add Game
            </button>
          </div>
        </div>
      )}

      <div className="grid gap-6">
        {games.length === 0 ? (
          <div className="bg-white rounded-lg shadow-lg p-6 text-center">
            <p className="text-gray-500 text-lg">No games found for this round</p>
          </div>
        ) : (
          games.map((game) => (
            <div key={game.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
              <div className="p-6">
                <div className="flex items-center justify-between">
                  {game.team1 && (
                    <div className="flex-1 text-center">
                      <div className="flex items-center justify-center space-x-2">
                        {game.team1?.region && (
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            game.team1.region === 'West' ? 'bg-blue-100 text-blue-800' :
                            game.team1.region === 'East' ? 'bg-green-100 text-green-800' :
                            game.team1.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                            {game.team1.region}
                          </span>
                        )}
                        <span className="text-sm font-semibold">#{game.team1.region_seed}</span>
                      </div>
                      <h3 className="text-xl font-bold mt-2">{game.team1.college}</h3>
                      <button
                        onClick={() => game.team1 && handleWinnerSelection(game, game.team1.id)}
                        disabled={saving || !game.team1}
                        className={`mt-4 px-4 py-2 rounded-md transition-colors ${
                          game.winner_id === game.team1?.id
                            ? 'bg-green-600 text-white'
                            : 'bg-gray-100 hover:bg-gray-200 text-gray-800'
                        }`}
                      >
                        {game.winner_id === game.team1?.id ? (
                          <div className="flex items-center justify-center space-x-2">
                            <Trophy size={16} />
                            <span>Winner</span>
                          </div>
                        ) : (
                          'Mark as Winner'
                        )}
                      </button>
                    </div>
                  )}

                  <div className="flex flex-col items-center justify-center px-8">
                    <div className="text-2xl font-bold text-gray-400">VS</div>
                    <div className="text-sm text-gray-500 mt-2">{game.round.name}</div>
                    {game.game_date && (
                      <div className="text-sm text-gray-500 mt-1">
                        {new Date(game.game_date).toLocaleString()}
                      </div>
                    )}
                  </div>

                  {game.team2 && (
                    <div className="flex-1 text-center">
                      <div className="flex items-center justify-center space-x-2">
                        {game.team2?.region && (
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            game.team2.region === 'West' ? 'bg-blue-100 text-blue-800' :
                            game.team2.region === 'East' ? 'bg-green-100 text-green-800' :
                            game.team2.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                            {game.team2.region}
                          </span>
                        )}
                        <span className="text-sm font-semibold">#{game.team2.region_seed}</span>
                      </div>
                      <h3 className="text-xl font-bold mt-2">{game.team2.college}</h3>
                      <button
                        onClick={() => game.team2 && handleWinnerSelection(game, game.team2.id)}
                        disabled={saving || !game.team2}
                        className={`mt-4 px-4 py-2 rounded-md transition-colors ${
                          game.winner_id === game.team2?.id
                            ? 'bg-green-600 text-white'
                            : 'bg-gray-100 hover:bg-gray-200 text-gray-800'
                        }`}
                      >
                        {game.winner_id === game.team2?.id ? (
                          <div className="flex items-center justify-center space-x-2">
                            <Trophy size={16} />
                            <span>Winner</span>
                          </div>
                        ) : (
                          'Mark as Winner'
                        )}
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default TournamentManagement;