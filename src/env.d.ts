/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly PUBLIC_SUPABASE_URL: string;
  readonly PUBLIC_SUPABASE_ANON_KEY: string;
  readonly SUPABASE_SERVICE_ROLE_KEY: string;
  readonly TINA_CLIENT_ID: string;
  readonly TINA_TOKEN: string;
  readonly GITHUB_BRANCH: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
