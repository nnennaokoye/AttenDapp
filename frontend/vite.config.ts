import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  },
  define: {
    'import.meta.env.VITE_WALLETCONNECT_PROJECT_ID': JSON.stringify('YOUR_WALLETCONNECT_PROJECT_ID'),
    'import.meta.env.VITE_ALCHEMY_API_KEY': JSON.stringify('YOUR_ALCHEMY_API_KEY')
  }
})