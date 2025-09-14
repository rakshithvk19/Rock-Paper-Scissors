# 🎮 Cross-VM Rock-Paper-Scissors Tournament

> Showcasing Fluent's revolutionary blended execution where Rust and Solidity contracts interact atomically without bridges

[![Built on Fluent](https://img.shields.io/badge/Built%20on-Fluent-blue)](https://fluent.xyz)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue)](https://soliditylang.org)
[![Rust](https://img.shields.io/badge/Rust-1.70+-orange)](https://rust-lang.org)
[![React](https://img.shields.io/badge/React-18.2-blue)](https://reactjs.org)

## 🚀 Quick Start

### 1. Setup
```bash
make setup           # Install everything + create env files
```

### 2. Get Testnet Tokens
```bash
make get-faucet      # Visit faucet to get test ETH
```

### 3. Deploy Contracts
```bash
make deploy-contracts # Interactive deployment process
```

### 4. Start Playing
```bash
make dev             # Start frontend at localhost:3000
```

## 🏗️ Architecture

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

### Component Breakdown

1. **🔮 Oracle (Rust)** - Pure randomness generation
2. **🤖 Computer AI (Rust)** - Game strategy & betting decisions  
3. **💰 Fund Manager (Solidity)** - Manages computer's betting funds
4. **🎮 Tournament (Solidity)** - Core game logic & payouts
5. **⚛️ Frontend (React)** - Modern web interface

## 🎯 Key Features

- **🎚️ Dynamic Betting** - Slider-based bet selection (0.001-0.1 ETH)
- **🧠 Smart Computer AI** - Pattern detection & adaptive betting
- **💸 Automatic Payouts** - Winner-takes-all or draw refunds
- **📊 Live Statistics** - Real-time game stats and history
- **🔗 MetaMask Integration** - Seamless wallet connection
- **📱 Responsive Design** - Works on desktop and mobile

## 🛠️ Development

### Available Commands
```bash
make help            # Show all available commands
make build           # Build all contracts
make test-rust       # Run Rust tests  
make test-game       # Test deployed contracts
make clean           # Clean build artifacts
make info            # Show project info
```

### Project Structure
```
├── contracts/              # Solidity contracts
├── rust-oracle/           # Randomness generation
├── rust-computer-ai/      # AI decision making
├── frontend/              # React web app
├── Makefile              # Build automation
└── gblend.config.js      # Fluent configuration
```

## 🌐 Network Details

- **Network**: Fluent Devnet
- **RPC**: https://rpc.dev.gblend.xyz/
- **Chain ID**: 20993
- **Explorer**: https://blockscout.dev.gblend.xyz/
- **Faucet**: https://faucet.dev.gblend.xyz/

## 🎮 How to Play

1. **Connect Wallet** - MetaMask with Fluent network
2. **Place Bet** - Use slider to select amount (0.001-0.1 ETH)
3. **Start Game** - Computer will also bet automatically
4. **Play Rounds** - Choose Rock 🪨, Paper 📄, or Scissors ✂️
5. **Win Prize** - Winner takes the entire pot!

## 🔧 Technical Highlights

### Cross-VM Innovation
- **Direct Function Calls** between Rust and Solidity
- **Atomic Transactions** - All operations succeed or fail together
- **Shared State** - Unified blockchain execution environment
- **No Bridges Required** - True real-time interaction

### Game Mechanics
- **Random Tournament Length** - 1-10 rounds determined by Oracle
- **Intelligent Computer** - Adaptive strategy with pattern recognition
- **Fair Betting System** - Computer bets based on game analysis
- **Transparent Randomness** - All random generation on-chain

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

MIT License

---

**Built with ❤️ using Fluent's blended execution to showcase the future of cross-VM blockchain development**
