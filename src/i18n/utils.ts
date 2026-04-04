import { es } from './es';
import { en } from './en';
import { ca } from './ca';

export type Lang = 'es' | 'en' | 'ca';

export const SUPPORTED_LANGS: Lang[] = ['es', 'en', 'ca'];
export const DEFAULT_LANG: Lang = 'es';

const translations = { es, en, ca };

export function getLangFromUrl(url: URL): Lang {
  const [, first] = url.pathname.split('/');
  if (first === 'en' || first === 'ca') return first;
  return 'es';
}

export function useTranslations(lang: Lang) {
  return translations[lang] ?? translations['es'];
}

export function getLocalePath(lang: Lang, path = '') {
  if (lang === DEFAULT_LANG) return `/${path}`;
  return `/${lang}/${path}`;
}

export const BELT_ORDER: Record<string, number> = {
  white: 0,
  yellow: 1,
  orange: 2,
  purple: 3,
  blue: 4,
  green: 5,
  brown: 6,
  black: 7,
};

export const BELTS = Object.keys(BELT_ORDER) as string[];

export function canAccessBelt(userBelt: string, requiredBelt: string): boolean {
  return (BELT_ORDER[userBelt] ?? 0) >= (BELT_ORDER[requiredBelt] ?? 0);
}
