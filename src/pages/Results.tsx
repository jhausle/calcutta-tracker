import React, { useState, useEffect } from 'react';
import { Calendar, Trophy } from 'lucide-react';
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
    owner: string | null;
  };
  team2: {
    id: string;
    college: string;
    region: string;
    region_seed: number;
    owner: string | null;
  };
  winner_id: string | null;
  game_date: string | null;
}

interface Season {
  id: string;
  year: number;
  name: string;
}

function Results() {
  const [rounds, setRounds] = useState<{ id: string; name: string; }[]>([]);
  const [selectedRound, setSelectedRound] = useState<string>('');
  const [games, setGames] = useState<Game[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [seasons, setSeasons] = useState<Season[]>([]);
  const [selectedYear, setSelectedYear] = useState<number>(new Date().getFullYear());
  const [seasonId, setSeasonId] = useState<string | null>(null);

  // Fetch available seasons
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

  // Get season ID when year changes
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

  // Fetch available rounds
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

  // Fetch games for selected round and season
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
              region_seed,
              owner:owner_id (
                name
              )
            ),
            team2:team2_id (
              id,
              college,
              region,
              region_seed,
              owner:owner_id (
                name
              )
            ),
            winner_id,
            game_date
          `)
          .eq('round_id', selectedRound)
          .eq('season_id', seasonId);

        if (gamesError) throw gamesError;

        const transformedGames: Game[] = (gamesData || []).map(game => ({
          id: game.id,
          round: {
            id: selectedRound,
            name: rounds.find(r => r.id === selectedRound)?.name || ''
          },
          team1: {
            id: game.team1.id,
            college: game.team1.college,
            region: game.team1.region,
            region_seed: game.team1.region_seed,
            owner: game.team1.owner?.name || null
          },
          team2: {
            id: game.team2.id,
            college: game.team2.college,
            region: game.team2.region,
            region_seed: game.team2.region_seed,
            owner: game.team2.owner?.name || null
          },
          winner_id: game.winner_id,
          game_date: game.game_date
        }));

        setGames(transformedGames);
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

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
        <strong className="font-bold">Error: </strong>
        <span className="block sm:inline">{error}</span>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-gray-900">Tournament Results</h1>
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
          <div className="flex items-center space-x-2">
            <Calendar className="text-gray-500" size={20} />
            <span className="text-gray-600 font-medium">{selectedYear} Tournament</span>
          </div>
        </div>
      </div>

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
                  <div className="flex-1 text-center">
                    <div className="flex items-center justify-center space-x-2">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        game.team1.region === 'West' ? 'bg-blue-100 text-blue-800' :
                        game.team1.region === 'East' ? 'bg-green-100 text-green-800' :
                        game.team1.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {game.team1.region}
                      </span>
                      <span className="text-sm font-semibold">#{game.team1.region_seed}</span>
                    </div>
                    <h3 className="text-xl font-bold mt-2">{game.team1.college}</h3>
                    {game.team1.owner && (
                      <p className="text-sm text-gray-600 mt-1">Owner: {game.team1.owner}</p>
                    )}
                    {game.winner_id === game.team1.id && (
                      <div className="flex items-center justify-center space-x-2 mt-4 text-green-600">
                        <Trophy size={20} />
                        <span className="font-medium">Winner</span>
                      </div>
                    )}
                  </div>

                  <div className="flex flex-col items-center justify-center px-8">
                    <div className="text-2xl font-bold text-gray-400">VS</div>
                    {game.game_date && (
                      <div className="text-sm text-gray-500 mt-2">
                        {new Date(game.game_date).toLocaleString()}
                      </div>
                    )}
                  </div>

                  <div className="flex-1 text-center">
                    <div className="flex items-center justify-center space-x-2">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        game.team2.region === 'West' ? 'bg-blue-100 text-blue-800' :
                        game.team2.region === 'East' ? 'bg-green-100 text-green-800' :
                        game.team2.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {game.team2.region}
                      </span>
                      <span className="text-sm font-semibold">#{game.team2.region_seed}</span>
                    </div>
                    <h3 className="text-xl font-bold mt-2">{game.team2.college}</h3>
                    {game.team2.owner && (
                      <p className="text-sm text-gray-600 mt-1">Owner: {game.team2.owner}</p>
                    )}
                    {game.winner_id === game.team2.id && (
                      <div className="flex items-center justify-center space-x-2 mt-4 text-green-600">
                        <Trophy size={20} />
                        <span className="font-medium">Winner</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default Results;