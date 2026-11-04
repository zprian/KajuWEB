/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        kaju: {
          red: '#C41E3A',
          dark: '#1A1A1A',
          gray: '#2D2D2D',
          light: '#F5F5F0',
        },
      },
      fontFamily: {
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
        heading: ['Barlow Condensed', 'Impact', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
