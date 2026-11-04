import { createServerClient } from '@supabase/ssr';
import type { AstroCookies } from 'astro';

function decodeCookieValue(value: string) {
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

export function createSupabaseServerClient(cookies: AstroCookies, request: Request) {
  return createServerClient(
    import.meta.env.PUBLIC_SUPABASE_URL,
    import.meta.env.PUBLIC_SUPABASE_ANON_KEY,
    {
      cookies: {
        getAll() {
          const header = request.headers.get('cookie') ?? '';
          if (!header) return [];

          return header.split(';').flatMap((part) => {
            const separator = part.indexOf('=');
            if (separator < 0) return [];
            return [{
              name: part.slice(0, separator).trim(),
              value: decodeCookieValue(part.slice(separator + 1).trim()),
            }];
          });
        },
        setAll(cookiesToSet) {
          for (const { name, value, options } of cookiesToSet) {
            cookies.set(name, value, options);
          }
        },
      },
    }
  );
}
