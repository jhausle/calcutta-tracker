import React, { useState, useEffect } from 'react';
import { User, Mail, DollarSign, Trophy, Calendar, ChevronDown, ChevronUp, Target } from 'lucide-react';
import { supabase } from '../lib/supabase';
import type { Owner, TeamEarnings } from '../types';

interface OwnerWithTeams {
  id: string;
  name: string;
  email: string;
  teams: any[];
  totalPurchasePrice: number;
  totalEarnings: number;
  totalProfit: number;
  taxAmount: number;
}

interface Season {
  id: string;
  year: number;
  name: string;
}

interface SpecialTeam {
  id: string;
  college: string;
  seed: number;
  team_score?: number;
}

function Owners() {
  const [owners, setOwners] = useState<OwnerWithTeams[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedOwners, setExpandedOwners] = useState<Set<string>>(new Set());
  const [seasons, setSeasons] = useState<Season[]>([]);
  const [selectedYear, setSelectedYear] = useState<number>(new Date().getFullYear());
  const [sweetSixteenTeam, setSweetSixteenTeam] = useState<SpecialTeam | null>(null);
  const [highestScoringLoser, setHighestScoringLoser] = useState<SpecialTeam | null>(null);
  const [specialPayoutsLoading, setSpecialPayoutsLoading] = useState(true);

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
    const fetchOwners = async () => {
      try {
        setLoading(true);
        
        // First, get all owners who have teams in the selected season
        const { data: ownersWithTeams, error: ownersError } = await supabase
          .from('owners')
          .select(`
            id,
            name,
            email,
            teams!teams_owner_id_fkey (
              season_id,
              seasons!teams_season_id_fkey (
                year
              )
            )
          `)
          .eq('teams.seasons.year', selectedYear)
          .order('name');

        if (ownersError) throw ownersError;

        // Then, fetch team earnings from the view
        const { data: teamEarnings, error: earningsError } = await supabase
          .from('team_earnings')
          .select('*')
          .eq('season_year', selectedYear);

        if (earningsError) throw earningsError;

        // Group team earnings by owner
        const ownerTeams = teamEarnings.reduce((acc, team) => {
          if (team.owner_name) {
            if (!acc[team.owner_name]) {
              acc[team.owner_name] = [];
            }
            acc[team.owner_name].push(team);
          }
          return acc;
        }, {} as Record<string, TeamEarnings[]>);

        // Combine owners with their teams and calculate totals
        const transformedOwners: OwnerWithTeams[] = (ownersWithTeams || [])
          .map(owner => {
            const teams = ownerTeams[owner.name] || [];
            const totalPurchasePrice = teams.reduce((sum: number, team: any) => sum + (team.purchase_price || 0), 0);
            const totalEarnings = teams.reduce((sum: number, team: any) => sum + (team.total_earnings || 0), 0);
            const totalProfit = teams.reduce((sum: number, team: any) => sum + ((team.total_earnings || 0) - (team.purchase_price || 0)), 0);
            const taxAmount = teams[0]?.owner_tax || 0;

            return {
              ...owner,
              teams,
              totalPurchasePrice,
              totalEarnings,
              totalProfit,
              taxAmount
            };
          })
          // Filter out owners with no teams in the selected season
          .filter(owner => owner.teams.length > 0);

        setOwners(transformedOwners);
        setError(null);
      } catch (err) {
        console.error('Error fetching owners:', err);
        setError(err instanceof Error ? err.message : 'Failed to load owners');
      } finally {
        setLoading(false);
      }
    };

    fetchOwners();
  }, [selectedYear]);

  useEffect(() => {
    const fetchSpecialPayouts = async () => {
      if (!selectedYear) return;
      
      try {
        setSpecialPayoutsLoading(true);
        
        // Fetch lowest seed to reach Sweet 16
        const { data: sweet16Data, error: sweet16Error } = await supabase
          .from('lowest_seed_sweet_16')
          .select('*')
          .eq('year', selectedYear)
          .maybeSingle();

        if (sweet16Error) throw sweet16Error;

        // Fetch highest scoring round 1 loser
        const { data: scoringData, error: scoringError } = await supabase
          .from('highest_scoring_r1_loser')
          .select('*')
          .eq('year', selectedYear)
          .maybeSingle();

        if (scoringError) throw scoringError;

        setSweetSixteenTeam(sweet16Data);
        setHighestScoringLoser(scoringData);
      } catch (err) {
        console.error('Error fetching special payouts:', err);
      } finally {
        setSpecialPayoutsLoading(false);
      }
    };

    fetchSpecialPayouts();
  }, [selectedYear]);

  const formatMoney = (amount: number | null) => {
    if (amount === null) return '$0.00';
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
  };

  const toggleOwner = (ownerId: string) => {
    setExpandedOwners(prev => {
      const next = new Set(prev);
      if (next.has(ownerId)) {
        next.delete(ownerId);
      } else {
        next.add(ownerId);
      }
      return next;
    });
  };

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
        <h1 className="text-3xl font-bold text-gray-900">Tournament Owners</h1>
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
            <span className="text-gray-600 font-medium">{selectedYear} Season</span>
          </div>
        </div>
      </div>

      {owners.length === 0 ? (
        <div className="bg-white rounded-lg shadow-lg p-6 text-center">
          <p className="text-gray-500 text-lg">No owners found for this season</p>
        </div>
      ) : (
        <div className="grid gap-6">
          {owners.map((owner) => (
            <div key={owner.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
              <div 
                className="p-6 border-b border-gray-200 cursor-pointer hover:bg-gray-50 transition-colors"
                onClick={() => toggleOwner(owner.id)}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-4">
                    <User className="text-blue-600" size={32} />
                    <div>
                      <h2 className="text-2xl font-bold text-gray-900">{owner.name}</h2>
                      <div className="flex items-center space-x-2 text-gray-600">
                        <Mail size={16} />
                        <span>{owner.email}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center space-x-8">
                    <div className="text-right">
                      <div className="text-sm text-gray-600">Total Purchases</div>
                      <div className="text-xl font-bold text-gray-900">{formatMoney(owner.totalPurchasePrice)}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm text-gray-600">Taxes</div>
                      <div className="text-xl font-bold text-gray-900">{formatMoney(owner.taxAmount)}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm text-gray-600">Net Profit</div>
                      <div className={`text-xl font-bold ${owner.totalProfit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {formatMoney(owner.totalProfit)}
                      </div>
                    </div>
                    {expandedOwners.has(owner.id) ? (
                      <ChevronUp className="text-gray-400" size={24} />
                    ) : (
                      <ChevronDown className="text-gray-400" size={24} />
                    )}
                  </div>
                </div>
              </div>

              {expandedOwners.has(owner.id) && (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Team</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Region</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Seed</th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Purchase Price</th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Total Earnings</th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Net Profit</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {owner.teams.map((team) => (
                        <tr key={team.team_id} className="hover:bg-gray-50">
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className="text-sm font-medium text-gray-900">{team.college}</span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                              team.region === 'West' ? 'bg-blue-100 text-blue-800' :
                              team.region === 'East' ? 'bg-green-100 text-green-800' :
                              team.region === 'South' ? 'bg-yellow-100 text-yellow-800' :
                              'bg-red-100 text-red-800'
                            }`}>
                              {team.region}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className="text-sm font-semibold text-gray-900">#{team.region_seed}</span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-right">
                            <div className="flex items-center justify-end space-x-1">
                              <DollarSign size={16} className="text-gray-400" />
                              <span className="text-sm text-gray-900">{formatMoney(team.purchase_price)}</span>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-right">
                            <div className="flex items-center justify-end space-x-1">
                              <Trophy size={16} className="text-green-500" />
                              <span className="text-sm font-medium text-green-600">{formatMoney(team.total_earnings)}</span>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-right">
                            <span className={`text-sm font-semibold ${(team.total_earnings || 0) >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                              {formatMoney(team.total_earnings)}
                            </span>
                          </td>
                        </tr>
                      ))}
                      <tr className="bg-gray-50 font-medium">
                        <td colSpan={3} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          Total
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm text-gray-900">
                          {formatMoney(owner.totalPurchasePrice)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm text-green-600">
                          {formatMoney(owner.totalEarnings)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                          <span className={owner.totalProfit >= 0 ? 'text-green-600' : 'text-red-600'}>
                            {formatMoney(owner.totalProfit)}
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      <div className="bg-white rounded-lg shadow p-6 space-y-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Special Payouts</h2>
        
        {specialPayoutsLoading ? (
          <div className="animate-pulse text-gray-500">Loading special payouts...</div>
        ) : (
          <div className="space-y-4">
            <div className="border-l-4 border-blue-500 pl-4">
              <div className="flex items-center space-x-2">
                <Trophy className="text-blue-500" size={24} />
                <h3 className="text-lg font-semibold">Lowest Seed to Sweet 16</h3>
              </div>
              {sweetSixteenTeam ? (
                <p className="mt-2">
                  #{sweetSixteenTeam.seed} {sweetSixteenTeam.college}
                </p>
              ) : (
                <p className="text-gray-500 mt-2">Not yet determined</p>
              )}
            </div>

            <div className="border-l-4 border-green-500 pl-4">
              <div className="flex items-center space-x-2">
                <Target className="text-green-500" size={24} />
                <h3 className="text-lg font-semibold">Highest Scoring R1 Loss</h3>
              </div>
              {highestScoringLoser ? (
                <p className="mt-2">
                  {highestScoringLoser.college} ({highestScoringLoser.team_score} pts)
                </p>
              ) : (
                <p className="text-gray-500 mt-2">Not yet determined</p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Owners;