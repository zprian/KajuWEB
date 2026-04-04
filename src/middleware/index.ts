import { defineMiddleware } from 'astro:middleware';
import { createSupabaseServerClient } from '../lib/supabase-server';

export const onRequest = defineMiddleware(async ({ url, cookies, redirect }, next) => {
  // Protect all /members/* routes
  const isMembersRoute = url.pathname.startsWith('/members') ||
    url.pathname.startsWith('/en/members') ||
    url.pathname.startsWith('/ca/members');

  if (isMembersRoute) {
    const supabase = createSupabaseServerClient(cookies);
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      const lang = url.pathname.startsWith('/en') ? '/en' : url.pathname.startsWith('/ca') ? '/ca' : '';
      return redirect(`${lang}/login`);
    }
  }

  return next();
});
