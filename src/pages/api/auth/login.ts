export const prerender = false;

import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../lib/supabase-server';

export const POST: APIRoute = async ({ request, cookies, redirect }) => {
  const formData = await request.formData();
  const email = formData.get('email')?.toString() ?? '';
  const password = formData.get('password')?.toString() ?? '';

  const supabase = createSupabaseServerClient(cookies);
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    return redirect('/login?error=1');
  }

  return redirect('/members');
};
