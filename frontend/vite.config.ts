import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/Cross-VM-Rock-Paper-Scissors/',
  // server: {
  //   port: 3000,
  // },
})
