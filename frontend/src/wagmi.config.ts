import { http, createConfig } from 'wagmi'
import { injected, metaMask } from 'wagmi/connectors'
import { FLUENT_RPC_URL, FLUENT_CHAIN_ID } from './utils/constants'

// Define Fluent chain
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
