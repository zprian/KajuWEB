export const prerender = false;

import type { APIRoute } from 'astro';
import { createSupabaseServerClient } from '../../../lib/supabase-server';

export const POST: APIRoute = async ({ request, cookies, redirect }) => {
  const formData = await request.formData();
  const email = formData.get('email')?.toString().trim().toLowerCase() ?? '';
  if (!email) return redirect('/login?reset=error');

  const supabase = createSupabaseServerClient(cookies, request);
  const siteUrl = import.meta.env.PUBLIC_SITE_URL || new URL(request.url).origin;
  const { error } = await supabase.auth.resetPasswordForEmail(email, { redirectTo: `${siteUrl}/login?type=recovery` });
  return redirect(`/login?reset=${error ? 'error' : 'sent'}`);
};
