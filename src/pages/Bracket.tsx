import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Trophy, Calendar } from 'lucide-react';

interface BracketTeam {
  id: string;
  college: string;
  region: string;
  region_seed: number;
  winner?: boolean;
  owner?: {
    name: string;
  } | null;
}

interface BracketGame {
  id: string;
  round: {
    id: string;
    name: string;
    round_number: number;
  };
  team1: BracketTeam | null;
  team2: BracketTeam | null;
  winner_id: string | null;
  game_number: number;
}

interface BracketRound {
  name: string;
  round_number: number;
  games: BracketGame[];
}

interface RegionRounds {
  region: string;
  rounds: BracketRound[];
}

interface Champion {
  id: string;
  college: string;
  region: string;
  region_seed: number;
  owner: {
    name: string;
  } | null;
}

interface Season {
  id: string;
  year: number;
  name: string;
}

function Bracket() {
  const [regionRounds, setRegionRounds] = useState<RegionRounds[]>([]);
  const [finalRounds, setFinalRounds] = useState<BracketRound[]>([]);
  const [champion, setChampion] = useState<Champion | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
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
    const fetchBracket = async () => {
      try {
        setLoading(true);
        setChampion(null);

        // Get the current season
        const { data: season, error: seasonError } = await supabase
          .from('seasons')
          .select(`
            id,
            champion:champion_team_id (
              id,
              college,
              region,
              region_seed,
              owner:owner_id (
                name
              )
            )
          `)
          .eq('year', selectedYear)
          .single();

        if (seasonError) throw seasonError;
        if (!season) throw new Error('Season not found');

        if (season.champion) {
          setChampion(season.champion);
        }

        // Get all games with their teams, owners, and rounds
        const { data: gamesData, error: gamesError } = await supabase
          .from('games')
          .select(`
            id,
            game_number,
            round:round_id (
              id,
              name,
              round_number
            ),
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
            winner_id
          `)
          .eq('season_id', season.id)
          .order('round(round_number)', { ascending: true })
          .order('game_number', { ascending: true });

        if (gamesError) throw gamesError;

        // Transform and organize the data by region and rounds
        const regionMap = new Map<string, Map<number, BracketRound>>();
        const finalRoundsMap = new Map<number, BracketRound>();

        gamesData.forEach((game: any) => {
          const roundNumber = game.round.round_number;
          const region = game.team1?.region || game.team2?.region;
          
          const transformedGame = {
            id: game.id,
            round: {
              id: game.round.id,
              name: game.round.name,
              round_number: roundNumber
            },
            team1: game.team1 ? {
              ...game.team1,
              winner: game.winner_id === game.team1.id
            } : null,
            team2: game.team2 ? {
              ...game.team2,
              winner: game.winner_id === game.team2.id
            } : null,
            winner_id: game.winner_id,
            game_number: game.game_number
          };

          // Final Four and Championship games go to finalRounds
          if (game.round.name === 'Final Four' || game.round.name === 'Championship') {
            if (!finalRoundsMap.has(roundNumber)) {
              finalRoundsMap.set(roundNumber, {
                name: game.round.name,
                round_number: roundNumber,
                games: []
              });
            }
            finalRoundsMap.get(roundNumber)?.games.push(transformedGame);
          }
          // Other games are organized by region
          else if (region) {
            if (!regionMap.has(region)) {
              regionMap.set(region, new Map());
            }
            
            const roundsMap = regionMap.get(region)!;
            if (!roundsMap.has(roundNumber)) {
              roundsMap.set(roundNumber, {
                name: game.round.name,
                round_number: roundNumber,
                games: []
              });
            }
            roundsMap.get(roundNumber)?.games.push(transformedGame);
          }
        });

        // Convert maps to arrays
        const regions: RegionRounds[] = Array.from(regionMap.entries()).map(([region, roundsMap]) => ({
          region,
          rounds: Array.from(roundsMap.values()).sort((a, b) => a.round_number - b.round_number)
        })).sort((a, b) => a.region.localeCompare(b.region));

        const finals = Array.from(finalRoundsMap.values()).sort((a, b) => a.round_number - b.round_number);

        setRegionRounds(regions);
        setFinalRounds(finals);
        setError(null);
      } catch (err) {
        console.error('Error fetching bracket:', err);
        setError('Failed to load tournament bracket');
      } finally {
        setLoading(false);
      }
    };

    fetchBracket();
  }, [selectedYear]);

  const BracketGame = ({ game }: { game: BracketGame }) => (
    <div className={`flex flex-col mb-4 ${game.round.round_number > 1 ? 'mt-8' : ''}`}>
      <div className={`flex flex-col border rounded-t p-2 ${
        game.winner_id === game.team1?.id ? 'bg-green-50 border-green-200' : 'bg-white'
      }`}>
        {game.team1 ? (
          <>
            <div className="flex items-center">
              <span className="w-6 text-sm font-semibold text-gray-600">#{game.team1.region_seed}</span>
              <span className={`flex-1 ml-2 ${game.winner_id === game.team1.id ? 'font-bold' : ''}`}>
                {game.team1.college}
              </span>
              <span className={`text-xs px-2 py-0.5 rounded ${
                game.team1.region === 'West' ? 'bg-blue-100 text-blue-800' :
                game.team1.region === 'East' ? 'bg-green-100 text-green-800' :
                game.team1.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                'bg-red-100 text-red-800'
              }`}>
                {game.team1.region}
              </span>
            </div>
            {game.team1.owner && (
              <div className="text-xs text-gray-500 mt-1 ml-8">
                Owner: {game.team1.owner.name}
              </div>
            )}
          </>
        ) : (
          <span className="flex-1 text-gray-400 text-sm italic">TBD</span>
        )}
      </div>
      <div className={`flex flex-col border-b border-l border-r rounded-b p-2 ${
        game.winner_id === game.team2?.id ? 'bg-green-50 border-green-200' : 'bg-white'
      }`}>
        {game.team2 ? (
          <>
            <div className="flex items-center">
              <span className="w-6 text-sm font-semibold text-gray-600">#{game.team2.region_seed}</span>
              <span className={`flex-1 ml-2 ${game.winner_id === game.team2.id ? 'font-bold' : ''}`}>
                {game.team2.college}
              </span>
              <span className={`text-xs px-2 py-0.5 rounded ${
                game.team2.region === 'West' ? 'bg-blue-100 text-blue-800' :
                game.team2.region === 'East' ? 'bg-green-100 text-green-800' :
                game.team2.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                'bg-red-100 text-red-800'
              }`}>
                {game.team2.region}
              </span>
            </div>
            {game.team2.owner && (
              <div className="text-xs text-gray-500 mt-1 ml-8">
                Owner: {game.team2.owner.name}
              </div>
            )}
          </>
        ) : (
          <span className="flex-1 text-gray-400 text-sm italic">TBD</span>
        )}
      </div>
    </div>
  );

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
        <h1 className="text-3xl font-bold text-gray-900">Tournament Bracket</h1>
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
          <div className="flex items-center space-x-2">
            <Calendar className="text-gray-500" size={20} />
            <span className="text-gray-600 font-medium">{selectedYear} NCAA Tournament</span>
          </div>
        </div>
      </div>

      {champion && (
        <div className="bg-gradient-to-r from-yellow-100 via-yellow-300 to-yellow-100 rounded-lg p-1">
          <div className="bg-white rounded-lg p-6">
            <div className="flex items-center justify-center space-x-4">
              <Trophy size={48} className="text-yellow-500" />
              <div className="text-center">
                <h2 className="text-2xl font-bold text-gray-900">Tournament Champion</h2>
                <div className="mt-2 flex items-center justify-center space-x-3">
                  <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                    champion.region === 'West' ? 'bg-blue-100 text-blue-800' :
                    champion.region === 'East' ? 'bg-green-100 text-green-800' :
                    champion.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-red-100 text-red-800'
                  }`}>
                    {champion.region}
                  </span>
                  <span className="text-lg font-semibold text-gray-700">#{champion.region_seed}</span>
                  <span className="text-2xl font-bold text-gray-900">{champion.college}</span>
                </div>
                {champion.owner && (
                  <div className="mt-2 text-gray-600">
                    Owner: {champion.owner.name}
                  </div>
                )}
              </div>
              <Trophy size={48} className="text-yellow-500" />
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {regionRounds.map(({ region, rounds }) => (
          <div key={region} className="bg-white rounded-lg shadow-lg p-6">
            <h2 className={`text-xl font-bold mb-6 ${
              region === 'West' ? 'text-blue-800' :
              region === 'East' ? 'text-green-800' :
              region === 'South' ? 'text-yellow-800' :
              'text-red-800'
            }`}>
              {region} Region
            </h2>
            <div className="flex overflow-x-auto pb-4">
              <div className="flex space-x-8">
                {rounds.map((round) => (
                  <div key={round.name} className="flex flex-col min-w-[300px]">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4 sticky top-0">
                      {round.name}
                    </h3>
                    <div className="space-y-8">
                      {round.games.map((game) => (
                        <BracketGame key={game.id} game={game} />
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {finalRounds.length > 0 && (
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-bold mb-6 text-purple-800">Final Rounds</h2>
          <div className="flex overflow-x-auto pb-4">
            <div className="flex space-x-8">
              {finalRounds.map((round) => (
                <div key={round.name} className="flex flex-col min-w-[300px]">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4 sticky top-0">
                    {round.name}
                  </h3>
                  <div className="space-y-8">
                    {round.games.map((game) => (
                      <BracketGame key={game.id} game={game} />
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Bracket;