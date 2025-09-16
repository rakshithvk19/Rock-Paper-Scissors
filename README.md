# Cross-VM Rock-Paper-Scissors Tournament

A demonstration of Fluent's blended execution capabilities, showcasing direct interoperability between Rust and Solidity smart contracts without bridges or external communication protocols.

[![Built on Fluent](https://img.shields.io/badge/Built%20on-Fluent-blue)](https://fluent.xyz)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue)](https://soliditylang.org)
[![Rust](https://img.shields.io/badge/Rust-1.70+-orange)](https://rust-lang.org)
[![React](https://img.shields.io/badge/React-18.2-blue)](https://reactjs.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview

This project demonstrates Fluent's revolutionary blended execution environment through a fully functional Rock-Paper-Scissors game with betting mechanics. The application showcases how Rust and Solidity contracts can interact atomically on the same blockchain, enabling developers to leverage the strengths of each language within a single application.

## Architecture Overview

### Smart Contract System
```
Player → Solidity Tournament → Rust Computer AI → Back to Solidity
         (Game Logic)          (Decision Making)    (Payouts)
                   ↓
              Rust Oracle
              (Randomness)
                   ↓
           Solidity Fund Manager
           (Computer's Money)
```

### Language Selection Rationale

**Rust Components:**
- **Oracle**: Implements deterministic randomness generation using Rust's mathematical operations and type safety
- **Computer AI**: Utilizes Rust's performance characteristics for pattern detection algorithms and strategic decision-making

**Solidity Components:**
- **Tournament**: Manages game state, player interactions, and financial transactions using Solidity's established DeFi patterns
- **Fund Manager**: Handles ETH transfers and balance management using Solidity's mature financial contract conventions

**Frontend:**
- **React Application**: Provides modern web interface with Web3 integration using wagmi and viem libraries

### Component Details

1. **Oracle (Rust)** - Pure randomness generation using deterministic algorithms
2. **Computer AI (Rust)** - Game strategy implementation with pattern recognition and adaptive betting logic
3. **Fund Manager (Solidity)** - Manages computer's betting funds with owner controls and betting limits
4. **Tournament (Solidity)** - Core game logic, state management, and payout distribution
5. **Frontend (React)** - User interface with MetaMask integration and real-time game statistics

## Key Features

- **Dynamic Betting System** - Configurable bet amounts with slider interface
- **Intelligent Computer Opponent** - Pattern detection and adaptive betting strategies
- **Automatic Payout Distribution** - Winner-takes-all or proportional refunds for draws
- **Real-time Game Statistics** - Live tracking of game progress and historical data
- **MetaMask Integration** - Seamless wallet connectivity with Fluent network support
- **Responsive Design** - Cross-platform compatibility for desktop and mobile devices

## Quick Start

### Prerequisites
- Node.js (v18+)
- Rust (1.70+)
- Foundry
- MetaMask or compatible wallet

### Installation
```bash
make install         # Install gblend CLI and Foundry
make get-devnet-tokens   # Get Fluent devnet tokens
```

### Contract Deployment
```bash
make deploy-oracle       # Deploy Rust Oracle contract
make deploy-computer-ai  # Deploy Rust Computer AI contract
make deploy-fund-manager # Deploy Solidity Fund Manager contract
make deploy-tournament   # Deploy Solidity Tournament contract
```

### Post-Deployment Setup
```bash
make fund-computer       # Fund computer with 0.02 ETH for betting
make setup-game-contract # Configure Fund Manager with Tournament address
```

### Start Frontend
```bash
make start-frontend      # Launch development server at localhost:3000
```

## Network Configuration

- **Network**: Fluent Devnet
- **RPC URL**: https://rpc.dev.gblend.xyz
- **Chain ID**: 20993
- **Explorer**: https://blockscout.dev.gblend.xyz
- **Faucet**: https://faucet.dev.gblend.xyz

## Development Commands

```bash
make help                    # Display all available commands
make generate-abis           # Generate TypeScript ABI files for frontend
make update-frontend-addresses  # Sync contract addresses to frontend
```

## Project Structure

```
├── contracts/              # Solidity smart contracts
│   ├── RPSTournament.sol   # Main game logic and state management
│   ├── FundManager.sol     # Computer betting fund management
│   └── interfaces/         # Contract interfaces for cross-language calls
├── rust-oracle/           # Rust randomness generation contract
├── rust-computer-ai/      # Rust AI decision-making contract
├── frontend/              # React web application
│   ├── src/components/    # React components
│   ├── src/contracts/     # Generated TypeScript ABIs
│   └── src/hooks/         # Web3 interaction hooks
├── foundry.toml           # Foundry configuration
├── Makefile              # Build and deployment automation
└── LICENSE               # MIT License
```

## Technical Implementation

### Cross-VM Communication

The application demonstrates Fluent's blended execution through direct function calls between virtual machines:

- **Solidity Tournament contract** calls **Rust Oracle** for randomness generation
- **Solidity Tournament contract** calls **Rust Computer AI** for move decisions and betting advice
- **Rust contracts** expose Solidity-compatible interfaces using `#[function_id]` attributes
- **All interactions** occur atomically within single transactions

### Game Mechanics

- **Tournament Length**: 1-10 rounds determined by Oracle randomness
- **Betting System**: Both player and computer place bets before game starts
- **AI Strategy**: Computer adapts betting amounts based on game analysis
- **Payout Logic**: Winner receives entire pot, draws return original bets
- **State Management**: Complete game state stored on-chain with move history

### Financial Flow

1. Player deposits ETH to Tournament contract via `startGame()`
2. Computer AI determines bet amount through strategy algorithms
3. Fund Manager transfers computer's ETH to Tournament contract
4. Tournament holds complete pot during gameplay
5. Payouts distributed based on final game results

## Why This Architecture

### Rust Components

**Oracle and Computer AI are implemented in Rust for:**
- **Performance**: Rust's zero-cost abstractions for mathematical operations
- **Safety**: Memory safety guarantees for complex algorithmic logic
- **Determinism**: Predictable behavior for randomness and AI calculations
- **Optimization**: Compiled efficiency for computational tasks

### Solidity Components

**Tournament and Fund Manager are implemented in Solidity for:**
- **Financial Operations**: Established patterns for ETH transfers and wallet interactions
- **State Management**: Mature tooling for complex state transitions and mappings
- **Ecosystem Integration**: Direct compatibility with existing DeFi infrastructure
- **Gas Optimization**: Well-understood gas patterns for financial contracts

### Cross-VM Benefits

This hybrid approach leverages the strengths of each language while maintaining atomic execution guarantees. Rust handles computational complexity while Solidity manages financial operations, all within Fluent's unified execution environment.

## Testing

The contracts include comprehensive testing capabilities:

```bash
# Test individual contract functions
cast call [CONTRACT_ADDRESS] "function_name()" --rpc-url https://rpc.dev.gblend.xyz

# Test cross-contract interactions
make test-game
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Network Information

**Fluent Devnet Configuration:**
- RPC: https://rpc.dev.gblend.xyz
- Chain ID: 20993
- Explorer: https://blockscout.dev.gblend.xyz
- Faucet: https://faucet.dev.gblend.xyz

**Tools Required:**
- gblend CLI (Rust contract deployment)
- Foundry (Solidity contract deployment and interaction)
- Node.js (Frontend development)
