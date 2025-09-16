//vite-env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_ORACLE_ADDRESS: string
  readonly VITE_COMPUTER_AI_ADDRESS: string
  readonly VITE_FUND_MANAGER_ADDRESS: string
  readonly VITE_TOURNAMENT_ADDRESS: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}