import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// GitHub Pages serves the site from /buoy-dock/; locally it runs from the root.
export default defineConfig({
  base: process.env.SITE_BASE ?? '/',
  plugins: [react(), tailwindcss()],
  server: { port: 5180, strictPort: true },
  build: { chunkSizeWarningLimit: 1200 },
})
