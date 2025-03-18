import { createClient } from '@supabase/supabase-js';
import { Database } from './database.types';

// Get environment variables with fallbacks for development
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://ehsizjxtzolmkkalxzmy.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoc2l6anh0em9sbWtrYWx4em15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0Nzk3NTUsImV4cCI6MjA1NzA1NTc1NX0.BuhOz6FtpvirA-TOBlIN4Y7udHe_UDEXHbyfMJmtHzw';

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey
);