export interface GameTeam {
  name: string;
  score: string;
  winner: boolean;
  rank?: number;
}

export interface Game {
  id: string;
  name: string;
  status: string;
  homeTeam: GameTeam;
  awayTeam: GameTeam;
}

export interface RoundEarnings {
  round64: number;
  round32: number;
  sweet16: number;
  elite8: number;
  final4: number;
  championship: number;
}

export interface TournamentResult {
  college: string;
  region: 'West' | 'East' | 'South' | 'Midwest';
  seed: number;
  owner: string;
  purchasePrice: number;
  seasonYear: number;
  seasonName: string;
  prizePool: number;
  rounds: {
    round64: boolean;
    round32: boolean;
    sweet16: boolean;
    elite8: boolean;
    final4: boolean;
    championship: boolean;
    winner: boolean;
  };
  earnings: RoundEarnings;
}

// Supabase database types
export interface Season {
  id: string;
  year: number;
  name: string;
  prize_pool: number;
  created_at: string;
}

export interface Owner {
  id: string;
  name: string;
  email: string;
  created_at: string;
}

export interface DatabaseTeam {
  id: string;
  college: string;
  region: 'West' | 'East' | 'South' | 'Midwest';
  overall_seed: number;
  region_seed: number;
  owner_id: string | null;
  season_id: string;
  purchase_price: number;
  created_at: string;
}

export interface Round {
  id: string;
  name: string;
  payout_percentage: number;
  created_at: string;
}

export interface TeamEarnings {
  team_id: string;
  season_id: string;
  season_year: number;
  season_name: string;
  prize_pool: number;
  college: string;
  region: 'West' | 'East' | 'South' | 'Midwest';
  overall_seed: number;
  region_seed: number;
  purchase_price: number;
  owner_name: string | null;
  owner_email: string | null;
  total_earnings: number;
  net_profit: number;
}