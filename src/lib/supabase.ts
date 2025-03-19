import { createClient } from '@supabase/supabase-js';
import { Database } from './database.types';

const supabaseUrl = 'https://ehsizjxtzolmkkalxzmy.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoc2l6anh0em9sbWtrYWx4em15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0Nzk3NTUsImV4cCI6MjA1NzA1NTc1NX0.BuhOz6FtpvirA-TOBlIN4Y7udHe_UDEXHbyfMJmtHzw';

if (!supabaseUrl) {
  throw new Error('Missing SUPABASE_URL');
}

if (!supabaseAnonKey) {
  throw new Error('Missing SUPABASE_ANON_KEY');
}

export const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey,
  {
    auth: {
      autoRefreshToken: true,
      persistSession: true
    }
  }
);