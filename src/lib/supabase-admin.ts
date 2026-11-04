import { createClient } from '@supabase/supabase-js';

export function createSupabaseAdminClient() {
  const secretKey = import.meta.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!secretKey || secretKey.startsWith('your-')) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY is not configured.');
  }

  return createClient(
    import.meta.env.PUBLIC_SUPABASE_URL,
    secretKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false,
      },
    }
  );
}
