export const VIEW_AS_ROLES = ['admin', 'instructor', 'member'] as const;
export type ViewAsRole = (typeof VIEW_AS_ROLES)[number];

export function getEffectiveRole(cookies: { get(name: string): { value?: string } | undefined }, actualRole: string | null | undefined): ViewAsRole {
  const safeActual = VIEW_AS_ROLES.includes(actualRole as ViewAsRole) ? actualRole as ViewAsRole : 'member';
  if (safeActual !== 'admin') return safeActual;
  const selected = cookies.get('kaju_view_as')?.value;
  return VIEW_AS_ROLES.includes(selected as ViewAsRole) ? selected as ViewAsRole : 'admin';
}
