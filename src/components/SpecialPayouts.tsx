import React, { useEffect, useState } from 'react';
import { Trophy, Target } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface SpecialTeam {
  id: string;
  college: string;
  seed: number;
  team_score?: number;
}

export default function SpecialPayouts() {
  const [sweetSixteenTeam, setSweetSixteenTeam] = useState<SpecialTeam | null>(null);
  const [highestScoringLoser, setHighestScoringLoser] = useState<SpecialTeam | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchSpecialPayouts = async () => {
      try {
        setLoading(true);
        
        // Fetch lowest seed to reach Sweet 16
        const { data: sweet16Data, error: sweet16Error } = await supabase
          .from('lowest_seed_sweet_16')
          .select('*')
          .eq('year', new Date().getFullYear())
          .single();

        if (sweet16Error && sweet16Error.code !== 'PGRST116') { // Ignore "no rows returned" error
          throw sweet16Error;
        }

        // Fetch highest scoring round 1 loser
        const { data: scoringData, error: scoringError } = await supabase
          .from('highest_scoring_r1_loser')
          .select('*')
          .eq('year', new Date().getFullYear())
          .single();

        if (scoringError && scoringError.code !== 'PGRST116') {
          throw scoringError;
        }

        setSweetSixteenTeam(sweet16Data);
        setHighestScoringLoser(scoringData);
        setError(null);
      } catch (err) {
        console.error('Error fetching special payouts:', err);
        setError('Failed to load special payouts');
      } finally {
        setLoading(false);
      }
    };

    fetchSpecialPayouts();
  }, []);

  if (loading) {
    return <div className="animate-pulse">Loading special payouts...</div>;
  }

  if (error) {
    return <div className="text-red-500">{error}</div>;
  }

  return (
    <div className="bg-white rounded-lg shadow p-6 space-y-6">
      <h2 className="text-2xl font-bold text-gray-900 mb-4">Special Payouts</h2>
      
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
    </div>
  );
} 