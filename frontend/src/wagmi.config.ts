import { http, createConfig } from 'wagmi'
import { injected, metaMask } from 'wagmi/connectors'
import { FLUENT_RPC_URL, FLUENT_CHAIN_ID } from './utils/constants'

/**
 * Fluent Chain Configuration
 * 
 * Defines the Fluent Devnet chain parameters for wagmi.
 * This includes RPC endpoints, chain ID, native currency, and block explorer.
 */
export const fluentChain = {
  id: FLUENT_CHAIN_ID,
  name: 'Fluent',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { http: [FLUENT_RPC_URL] },
    public: { http: [FLUENT_RPC_URL] },
  },
  blockExplorers: {
    default: { name: 'Blockscout', url: 'https://blockscout.dev.gblend.xyz/' },
  },
} as const

/**
 * Wagmi Configuration
 * 
 * Main configuration for Web3 functionality.
 * Sets up:
 * - Supported chains (Fluent Devnet)
 * - Wallet connectors (Injected wallets, MetaMask)
 * - Transport layer (HTTP RPC)
 */
export const config = createConfig({
  chains: [fluentChain],
  connectors: [
    injected(),
    metaMask(),
  ],
  transports: {
    [fluentChain.id]: http(),
  },
})
