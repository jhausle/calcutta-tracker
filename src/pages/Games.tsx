import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { format } from 'date-fns';
import { Calendar, Trophy } from 'lucide-react';
import { Game } from '../types';
import { supabase } from '../lib/supabase';

interface TournamentGame {
  id: string;
  team1: {
    id: string;
    college: string;
  };
  team2: {
    id: string;
    college: string;
  };
  winner_id: string | null;
}

interface TeamMapping {
  espnName: string;
  tournamentName: string;
}

// Map of known team name variations
const teamMappings: TeamMapping[] = [
  { espnName: "UNC", tournamentName: "North Carolina" },
  { espnName: "NC State", tournamentName: "North Carolina State" },
  { espnName: "SDSU", tournamentName: "San Diego State" },
  { espnName: "UConn", tournamentName: "Connecticut" },
  { espnName: "St. Mary's", tournamentName: "Saint Marys" },
];

function normalizeTeamName(name: string): string {
  // Remove special characters and convert to lowercase
  return name.toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function matchTeamNames(espnName: string, tournamentName: string): boolean {
  // First check the mapping table
  const mapping = teamMappings.find(m => 
    normalizeTeamName(m.espnName) === normalizeTeamName(espnName)
  );
  
  if (mapping) {
    return normalizeTeamName(mapping.tournamentName) === normalizeTeamName(tournamentName);
  }

  // Then try direct comparison
  return normalizeTeamName(espnName) === normalizeTeamName(tournamentName);
}

function Games() {
  const [date, setDate] = useState(new Date());
  const [games, setGames] = useState<Game[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [syncing, setSyncing] = useState(false);
  const [tournamentGames, setTournamentGames] = useState<TournamentGame[]>([]);

  useEffect(() => {
    const fetchTournamentGames = async () => {
      try {
        const { data: season } = await supabase
          .from('seasons')
          .select('id')
          .eq('year', new Date().getFullYear())
          .single();

        if (season) {
          const { data: games, error } = await supabase
            .from('games')
            .select(`
              id,
              team1:team1_id (
                id,
                college
              ),
              team2:team2_id (
                id,
                college
              ),
              winner_id
            `)
            .eq('season_id', season.id)
            .is('winner_id', null);

          if (error) throw error;
          const transformedGames: TournamentGame[] = games.map(game => ({
            id: game.id,
            team1: {
              id: game.team1?.[0]?.id || '',
              college: game.team1?.[0]?.college || ''
            },
            team2: {
              id: game.team2?.[0]?.id || '',
              college: game.team2?.[0]?.college || ''
            },
            winner_id: game.winner_id
          }));
          setTournamentGames(transformedGames);
        }
      } catch (err) {
        console.error('Error fetching tournament games:', err);
      }
    };

    fetchTournamentGames();
  }, []);

  useEffect(() => {
    const fetchGames = async () => {
      setLoading(true);
      try {
        const formattedDate = format(date, 'yyyyMMdd');
        const response = await axios.get(
          `https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/scoreboard?dates=${formattedDate}`
        );
        
        const formattedGames = response.data.events.map((event: any) => ({
          id: event.id,
          name: event.name,
          status: event.status.type.shortDetail,
          homeTeam: {
            name: event.competitions[0].competitors[0].team.location,
            score: event.competitions[0].competitors[0].score,
            winner: event.competitions[0].competitors[0].winner,
            rank: event.competitions[0].competitors[0].curatedRank?.current
          },
          awayTeam: {
            name: event.competitions[0].competitors[1].team.location,
            score: event.competitions[0].competitors[1].score,
            winner: event.competitions[0].competitors[1].winner,
            rank: event.competitions[0].competitors[1].curatedRank?.current
          }
        }));

        setGames(formattedGames);
        setError(null);
      } catch (err) {
        setError('Failed to fetch games. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    fetchGames();
  }, [date]);

  const findMatchingTournamentGame = (espnGame: Game): TournamentGame | null => {
    return tournamentGames.find(tGame => 
      (matchTeamNames(espnGame.homeTeam.name, tGame.team1.college) &&
       matchTeamNames(espnGame.awayTeam.name, tGame.team2.college)) ||
      (matchTeamNames(espnGame.homeTeam.name, tGame.team2.college) &&
       matchTeamNames(espnGame.awayTeam.name, tGame.team1.college))
    ) || null;
  };

  const syncGameResult = async (espnGame: Game, tournamentGame: TournamentGame) => {
    try {
      setSyncing(true);

      const winningTeamName = espnGame.homeTeam.winner ? 
        espnGame.homeTeam.name : 
        espnGame.awayTeam.name;

      const winnerTeamId = matchTeamNames(winningTeamName, tournamentGame.team1.college) ?
        tournamentGame.team1.id :
        tournamentGame.team2.id;

      const { error } = await supabase.rpc('advance_to_next_round', {
        game_id: tournamentGame.id,
        winner_team_id: winnerTeamId
      });

      if (error) throw error;

      // Remove the synced game from tournamentGames
      setTournamentGames(prev => 
        prev.filter(game => game.id !== tournamentGame.id)
      );

      setError(null);
    } catch (err) {
      console.error('Error syncing game result:', err);
      setError('Failed to sync game result');
    } finally {
      setSyncing(false);
    }
  };

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-900">Games for {format(date, 'MMMM d, yyyy')}</h2>
        <div className="flex items-center space-x-2">
          <Calendar size={20} className="text-gray-500" />
          <input
            type="date"
            value={format(date, 'yyyy-MM-dd')}
            onChange={(e) => {
              const [year, month, day] = e.target.value.split('-').map(Number);
              setDate(new Date(year, month - 1, day, 12)); // Set to noon to avoid timezone issues
            }}
            className="px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>

      {loading ? (
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
      ) : error ? (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
          <strong className="font-bold">Error: </strong>
          <span className="block sm:inline">{error}</span>
        </div>
      ) : games.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <p className="text-gray-500 text-lg">No games scheduled for this date.</p>
        </div>
      ) : (
        <div className="grid gap-4">
          {games.map((game) => {
            const matchingGame = game.status === 'Final' ? findMatchingTournamentGame(game) : null;
            
            return (
              <div key={game.id} className="bg-white rounded-lg shadow-md p-6">
                <div className="flex justify-between items-center">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2">
                      {game.awayTeam.rank && (
                        <span className="text-sm font-semibold text-blue-600">#{game.awayTeam.rank}</span>
                      )}
                      <span className={`text-lg font-medium ${game.awayTeam.winner ? 'text-green-600' : ''}`}>
                        {game.awayTeam.name}
                      </span>
                    </div>
                    <div className="text-3xl font-bold mt-1">{game.awayTeam.score || '-'}</div>
                  </div>
                  <div className="px-4">
                    <div className="text-sm font-medium text-gray-500">{game.status}</div>
                    <div className="text-2xl font-bold">@</div>
                  </div>
                  <div className="flex-1 text-right">
                    <div className="flex items-center justify-end space-x-2">
                      {game.homeTeam.rank && (
                        <span className="text-sm font-semibold text-blue-600">#{game.homeTeam.rank}</span>
                      )}
                      <span className={`text-lg font-medium ${game.homeTeam.winner ? 'text-green-600' : ''}`}>
                        {game.homeTeam.name}
                      </span>
                    </div>
                    <div className="text-3xl font-bold mt-1">{game.homeTeam.score || '-'}</div>
                  </div>
                </div>

                {matchingGame && !matchingGame.winner_id && (
                  <div className="mt-4 flex justify-end">
                    <button
                      onClick={() => syncGameResult(game, matchingGame)}
                      disabled={syncing}
                      className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 transition-colors disabled:opacity-50"
                    >
                      <Trophy size={20} />
                      <span>Sync Tournament Result</span>
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

export default Games;