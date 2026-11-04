import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../lib/supabase-server';

const allowedTypes = new Set(['magiclink', 'email', 'invite', 'recovery', 'signup']);

export const GET: APIRoute = async ({ url, request, cookies, redirect }) => {
  const code = url.searchParams.get('code');
  const requestedType = url.searchParams.get('type') ?? 'magiclink';
  const type = allowedTypes.has(requestedType) ? requestedType : 'magiclink';

  if (!code) return redirect(`/login?type=${type}&error=callback`);

  const supabase = createSupabaseServerClient(cookies, request);
  const { error } = await supabase.auth.exchangeCodeForSession(code);

  if (!error && type === 'invite') {
    await supabase.auth.signOut();
    return redirect('/login?confirmed=1');
  }

  return redirect(`/login?type=${type}&callback=ready${error ? '&error=callback' : ''}`);
};
