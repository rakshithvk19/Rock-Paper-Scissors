# Cross-VM Rock Paper Scissors Frontend

A React frontend for the Cross-VM Rock Paper Scissors game built on Fluent's blended execution network.

## Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Environment configuration**
   ```bash
   cp .env.example .env
   ```
   Update the `.env` file with deployed contract addresses.

3. **Start development server**
   ```bash
   npm run dev
   ```

4. **Connect MetaMask**
   - Network: Fluent Testnet
   - RPC URL: https://rpc.dev.gblend.xyz/
   - Chain ID: 20993
   - Get testnet tokens: https://faucet.dev.gblend.xyz/

## Features

- 🎮 Play Rock Paper Scissors against AI
- 💰 Betting system with adjustable amounts
- 📊 Real-time game stats and history
- 🔗 MetaMask wallet integration
- 📱 Responsive design with Tailwind CSS
- ⚡ Cross-VM contract interactions (Rust + Solidity)

## Tech Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Fast development server
- **Tailwind CSS** - Styling
- **wagmi** - Ethereum React hooks
- **viem** - Modern Ethereum library
