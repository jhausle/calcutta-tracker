export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      owners: {
        Row: {
          id: string
          name: string
          email: string
          created_at: string | null
        }
        Insert: {
          id?: string
          name: string
          email: string
          created_at?: string | null
        }
        Update: {
          id?: string
          name?: string
          email?: string
          created_at?: string | null
        }
      }
      rounds: {
        Row: {
          id: string
          name: string
          payout_percentage: number
          created_at: string | null
        }
        Insert: {
          id?: string
          name: string
          payout_percentage: number
          created_at?: string | null
        }
        Update: {
          id?: string
          name?: string
          payout_percentage?: number
          created_at?: string | null
        }
      }
      seasons: {
        Row: {
          id: string
          year: number
          name: string
          prize_pool: number
          created_at: string | null
        }
        Insert: {
          id?: string
          year: number
          name: string
          prize_pool: number
          created_at?: string | null
        }
        Update: {
          id?: string
          year?: number
          name?: string
          prize_pool?: number
          created_at?: string | null
        }
      }
      team_results: {
        Row: {
          id: string
          team_id: string
          round_id: string
          won: boolean
          created_at: string | null
          season_id: string
        }
        Insert: {
          id?: string
          team_id: string
          round_id: string
          won: boolean
          created_at?: string | null
          season_id: string
        }
        Update: {
          id?: string
          team_id?: string
          round_id?: string
          won?: boolean
          created_at?: string | null
          season_id?: string
        }
      }
      teams: {
        Row: {
          id: string
          college: string
          region: string
          overall_seed: number
          region_seed: number
          owner_id: string | null
          created_at: string | null
          season_id: string
          purchase_price: number
        }
        Insert: {
          id?: string
          college: string
          region: string
          overall_seed: number
          region_seed: number
          owner_id?: string | null
          created_at?: string | null
          season_id: string
          purchase_price: number
        }
        Update: {
          id?: string
          college?: string
          region?: string
          overall_seed?: number
          region_seed?: number
          owner_id?: string | null
          created_at?: string | null
          season_id?: string
          purchase_price?: number
        }
      }
    }
    Views: {
      team_earnings: {
        Row: {
          team_id: string | null
          season_id: string | null
          season_year: number | null
          season_name: string | null
          prize_pool: number | null
          college: string | null
          region: string | null
          overall_seed: number | null
          region_seed: number | null
          purchase_price: number | null
          owner_name: string | null
          owner_email: string | null
          total_earnings: number | null
          net_profit: number | null
        }
      }
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}