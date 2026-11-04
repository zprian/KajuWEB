import { defineConfig } from 'tinacms';

export default defineConfig({
  // Replace with your TinaCloud clientId and token after creating a project at app.tina.io
  clientId: process.env.TINA_CLIENT_ID ?? '',
  token: process.env.TINA_TOKEN ?? '',
  branch: process.env.GITHUB_BRANCH ?? 'main',

  build: {
    outputFolder: 'admin',
    publicFolder: 'public',
  },
  media: {
    tina: {
      mediaRoot: 'images',
      publicFolder: 'public',
    },
  },

  schema: {
    collections: [
      // ── Page sections ────────────────────────────────────────────
      {
        name: 'page',
        label: 'Secciones de página',
        path: 'content/pages',
        format: 'md',
        fields: [
          { name: 'slug', label: 'ID de sección', type: 'string', required: true, isTitle: true },
          { name: 'title_es', label: 'Título (ES)', type: 'string' },
          { name: 'title_en', label: 'Título (EN)', type: 'string' },
          { name: 'title_ca', label: 'Títol (CA)', type: 'string' },
          { name: 'body_es', label: 'Contenido (ES)', type: 'rich-text' },
          { name: 'body_en', label: 'Content (EN)', type: 'rich-text' },
          { name: 'body_ca', label: 'Contingut (CA)', type: 'rich-text' },
        ],
      },

      // ── News ─────────────────────────────────────────────────────
      {
        name: 'news',
        label: 'Noticias',
        path: 'content/news',
        format: 'md',
        defaultItem: () => ({ date: new Date().toISOString().split('T')[0] }),
        fields: [
          { name: 'title_es', label: 'Título (ES)', type: 'string', required: true, isTitle: true },
          { name: 'title_en', label: 'Title (EN)', type: 'string' },
          { name: 'title_ca', label: 'Títol (CA)', type: 'string' },
          { name: 'date', label: 'Fecha', type: 'datetime', ui: { dateFormat: 'YYYY-MM-DD' } },
          { name: 'image', label: 'Imagen', type: 'image' },
          { name: 'summary_es', label: 'Resumen (ES)', type: 'string', ui: { component: 'textarea' } },
          { name: 'summary_en', label: 'Summary (EN)', type: 'string', ui: { component: 'textarea' } },
          { name: 'summary_ca', label: 'Resum (CA)', type: 'string', ui: { component: 'textarea' } },
          { name: 'body_es', label: 'Contenido (ES)', type: 'rich-text' },
          { name: 'body_en', label: 'Content (EN)', type: 'rich-text' },
          { name: 'body_ca', label: 'Contingut (CA)', type: 'rich-text' },
        ],
      },

      // ── Schedule ─────────────────────────────────────────────────
      {
        name: 'schedule',
        label: 'Horario',
        path: 'content/schedule',
        format: 'md',
        fields: [
          { name: 'title', label: 'Título', type: 'string', required: true, isTitle: true },
          {
            name: 'entries',
            label: 'Clases',
            type: 'object',
            list: true,
            fields: [
              { name: 'day_es', label: 'Día (ES)', type: 'string' },
              { name: 'day_en', label: 'Day (EN)', type: 'string' },
              { name: 'day_ca', label: 'Dia (CA)', type: 'string' },
              { name: 'time', label: 'Horario', type: 'string' },
              { name: 'class_es', label: 'Clase (ES)', type: 'string' },
              { name: 'class_en', label: 'Class (EN)', type: 'string' },
              { name: 'class_ca', label: 'Classe (CA)', type: 'string' },
              { name: 'location', label: 'Lugar', type: 'string' },
            ],
          },
        ],
      },

      // ── Member content (belt-gated) ───────────────────────────────
      {
        name: 'memberContent',
        label: 'Contenido de miembros (por cinturón)',
        path: 'content/members',
        format: 'md',
        fields: [
          {
            name: 'belt',
            label: 'Cinturón mínimo requerido',
            type: 'string',
            required: true,
            isTitle: true,
            options: ['white', 'yellow', 'orange', 'purple', 'blue', 'green', 'brown', 'black'],
          },
          { name: 'title_es', label: 'Título (ES)', type: 'string' },
          { name: 'title_en', label: 'Title (EN)', type: 'string' },
          { name: 'title_ca', label: 'Títol (CA)', type: 'string' },
          { name: 'body_es', label: 'Contenido (ES)', type: 'rich-text' },
          { name: 'body_en', label: 'Content (EN)', type: 'rich-text' },
          { name: 'body_ca', label: 'Contingut (CA)', type: 'rich-text' },
        ],
      },
    ],
  },
});
