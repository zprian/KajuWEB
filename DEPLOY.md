# KajuWEB — Guía de despliegue

## Requisitos previos
- Cuenta en [GitHub](https://github.com)
- Cuenta en [Netlify](https://netlify.com) (gratis)
- Cuenta en [Supabase](https://supabase.com) (gratis)
- Cuenta en [TinaCloud](https://app.tina.io) (gratis, máx. 2 editores)
- [Node.js 22+](https://nodejs.org) instalado en tu ordenador
- [Git](https://git-scm.com) instalado en tu ordenador

---

## Paso 1 — Subir el código a GitHub

```bash
# Dentro de la carpeta del proyecto
git init
git add .
git commit -m "Initial commit"
```

Crea un nuevo repositorio en GitHub (github.com → New repository) y luego:

```bash
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git branch -M main
git push -u origin main
```

---

## Paso 2 — Configurar Supabase

1. Ve a [supabase.com](https://supabase.com) → **New project**
2. Elige un nombre, contraseña y región (Europe West es lo más cercano)
3. Espera a que el proyecto se inicialice (~2 minutos)
4. Ve a **SQL Editor** (menú izquierdo) → **New query**
5. Copia y pega el contenido del archivo `supabase-schema.sql` y haz clic en **Run**
6. Ejecuta después el archivo `supabase-seed.sql`. Crea las 96 posiciones de técnicas como borradores no publicados (8 cinturones × 6 categorías × 2 posiciones).
7. Ve a **Project Settings → API** y copia:
   - `Project URL` → será tu `PUBLIC_SUPABASE_URL`
   - `anon public` key → será tu `PUBLIC_SUPABASE_ANON_KEY`

### Añadir el primer miembro (admin)
1. Ve a **Authentication → Users → Invite user**
2. Introduce el correo del administrador
3. Una vez que acepte la invitación, ve a **SQL Editor** y ejecuta:
   ```sql
   UPDATE public.profiles
   SET name = 'Nombre', surname = 'Apellidos', belt = 'black', role = 'admin'
   WHERE id = (SELECT id FROM auth.users WHERE email = 'correo@ejemplo.com');
   ```

---

## Paso 3 — Configurar TinaCloud

1. Ve a [app.tina.io](https://app.tina.io) → **New project**
2. Conecta tu cuenta de GitHub y selecciona el repositorio
3. **Salta el paso de despliegue** (busca "Skip" o "I'll deploy myself") — no necesitas Vercel
4. Una vez creado el proyecto, ve a **Project Settings → API Tokens**
5. Copia:
   - `Client ID` → será tu `TINA_CLIENT_ID`
   - `Token` → será tu `TINA_TOKEN`

---

## Paso 4 — Desplegar en Netlify

1. Ve a [netlify.com](https://netlify.com) → **Add new site → Import an existing project**
2. Selecciona **GitHub** y autoriza el acceso
3. Elige tu repositorio
4. Netlify detectará la configuración automáticamente desde `netlify.toml`. Verifica:
   - **Build command:** `npm run build`
   - **Publish directory:** `dist`
5. Antes de hacer el primer deploy, ve a **Site configuration → Environment variables** y añade todas estas variables:

   | Variable | Valor |
   |---|---|
   | `PUBLIC_SUPABASE_URL` | El Project URL de Supabase |
   | `PUBLIC_SUPABASE_ANON_KEY` | La clave anon de Supabase |
   | `TINA_CLIENT_ID` | El Client ID de TinaCloud |
   | `TINA_TOKEN` | El Token de TinaCloud |
   | `GITHUB_BRANCH` | `main` |

6. Haz clic en **Deploy site**
7. Una vez desplegado, Netlify te dará una URL del tipo `https://algo-aleatorio.netlify.app`

---

## Paso 5 — Conectar tu dominio

1. En Netlify → **Domain management → Add a domain**
2. Introduce tu dominio (ej. `kajukenbocatalunya.cat`)
3. Netlify te dará unos **nameservers** o un registro DNS para añadir
4. Ve al panel de tu registrador de dominio y actualiza los DNS según las instrucciones de Netlify
5. El certificado SSL (HTTPS) se genera automáticamente y gratis

---

## Paso 6 — Verificar que todo funciona

| URL | Qué comprobar |
|---|---|
| `https://tudominio.com` | Página principal en español |
| `https://tudominio.com/en` | Página en inglés |
| `https://tudominio.com/ca` | Página en catalán |
| `https://tudominio.com/login` | Formulario de acceso de miembros |
| `https://tudominio.com/members` | Redirige a `/login` si no hay sesión |
| `https://tudominio.com/admin` | Panel de edición de TinaCMS |

---

## Paso 7 — Usar el panel de edición (TinaCMS)

1. Ve a `https://tudominio.com/admin`
2. Inicia sesión con tu cuenta de TinaCloud
3. Desde aquí puedes editar:
   - **Secciones de página** — Historia, Ángel García, Catalunya
   - **Noticias** — Añadir, editar y eliminar noticias
   - **Horario** — Modificar los días y horarios de clases
   - **Contenido de miembros** — Añadir contenido por nivel de cinturón
4. Al guardar, TinaCMS hace un commit automático en GitHub, lo que dispara un nuevo deploy en Netlify (~1-2 minutos)

---

## Paso 8 — Gestionar miembros

Los miembros se gestionan desde el panel de Supabase:

### Invitar a un nuevo miembro
1. Ve a Supabase → **Authentication → Users → Invite user**
2. El usuario recibirá un email para establecer su contraseña

### Cambiar el cinturón de un miembro
1. Ve a Supabase → **SQL Editor** y ejecuta:
   ```sql
   UPDATE public.profiles
   SET belt = 'blue'
   WHERE id = (SELECT id FROM auth.users WHERE email = 'correo@miembro.com');
   ```
   Los valores válidos son: `white`, `yellow`, `orange`, `purple`, `blue`, `green`, `brown`, `black`

### Ver todos los miembros
1. Ve a Supabase → **Table Editor → profiles**

---

## Actualizar el Instagram

La cuenta configurada es `kajukenbobcn`. Si cambia en el futuro, edita `src/components/InstagramEmbed.astro`:

```astro
const { lang, instagramHandle = 'TU_USUARIO_INSTAGRAM' } = Astro.props;
```

Luego haz commit y push — Netlify desplegará automáticamente.

---

## Flujo de actualizaciones futuras

Cualquier cambio en el código se despliega automáticamente:

```bash
git add .
git commit -m "Descripción del cambio"
git push
```

Netlify detecta el push y redespliega el sitio en 1-2 minutos.
