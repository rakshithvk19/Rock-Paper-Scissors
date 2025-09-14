# Makefile for Cross-VM Rock-Paper-Scissors Tournament

-include .env

.PHONY: help install build deploy clean

help: ## Show this help message
	@echo 'Cross-VM Rock-Paper-Scissors Tournament'
	@echo '======================================='
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Setup:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && /Setup:/ {found=1} found && /^[a-zA-Z_-]+:.*?## / && !/Setup:/ {if(/^[[:space:]]*$$/ || /^#/) found=0; else printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Build:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && /Build:/ {found=1} found && /^[a-zA-Z_-]+:.*?## / && !/Build:/ {if(/^[[:space:]]*$$/ || /^#/) found=0; else printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Deploy:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && /Deploy:/ {found=1} found && /^[a-zA-Z_-]+:.*?## / && !/Deploy:/ {if(/^[[:space:]]*$$/ || /^#/) found=0; else printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Development:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && /Development:/ {found=1} found && /^[a-zA-Z_-]+:.*?## / && !/Development:/ {if(/^[[:space:]]*$$/ || /^#/) found=0; else printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup
install: ## Setup: Install gblend and all dependencies
	@echo "🔧 Installing gblend CLI..."
	cargo install gblend
	@echo "🦀 Installing Rust dependencies..."
	cd rust-oracle && cargo build
	cd rust-computer-ai && cargo build
	@echo "⚛️  Installing frontend dependencies..."
	cd frontend && npm install
	@echo "✅ All dependencies installed!"

setup: ## Setup: Complete project setup (install + env files)
	@echo "🚀 Setting up Cross-VM RPS Tournament..."
	make install
	cp .env.example .env
	cd frontend && cp .env.example .env
	@echo ""
	@echo "✅ Setup complete!"
	@echo "📝 Next steps:"
	@echo "   1. Edit .env with your private key"
	@echo "   2. Get testnet tokens: make get-faucet"
	@echo "   3. Deploy contracts: make deploy-all"
	@echo "   4. Update contract addresses in frontend"
	@echo "   5. Start frontend: make dev"

get-faucet: ## Setup: Get testnet tokens
	@echo "💰 Get Fluent testnet tokens:"
	@echo "   🌐 Visit: https://faucet.dev.gblend.xyz/"
	@echo "   📋 Enter your wallet address to get testnet ETH"

# Build
build-rust: ## Build: Build all Rust contracts
	@echo "🦀 Building Rust contracts..."
	@echo "   📦 Building Oracle..."
	cd rust-oracle && cargo build --release --target wasm32-unknown-unknown
	@echo "   🤖 Building Computer AI..."
	cd rust-computer-ai && cargo build --release --target wasm32-unknown-unknown
	@echo "✅ Rust contracts built!"

build-solidity: ## Build: Build Solidity contracts
	@echo "⚡ Building Solidity contracts..."
	gblend build sol
	@echo "✅ Solidity contracts built!"

build-frontend: ## Build: Build frontend for production
	@echo "⚛️  Building frontend..."
	cd frontend && npm run build
	@echo "✅ Frontend built!"

build: build-rust build-solidity ## Build: Build all contracts

build-all: build build-frontend ## Build: Build contracts and frontend

# Deploy
deploy-oracle: ## Deploy: Deploy Rust Oracle contract
	@echo "🔮 Deploying Oracle contract..."
	@echo "   📍 Network: Fluent Devnet"
	cd rust-oracle && gblend deploy --network fluent
	@echo "✅ Oracle deployed!"
	@echo "📋 Copy the deployed address to .env as ORACLE_ADDRESS"

deploy-computer-ai: ## Deploy: Deploy Computer AI contract
	@echo "🤖 Deploying Computer AI contract..."
	@echo "   📍 Network: Fluent Devnet"
	cd rust-computer-ai && gblend deploy --network fluent
	@echo "✅ Computer AI deployed!"
	@echo "📋 Copy the deployed address to .env as COMPUTER_AI_ADDRESS"

deploy-fund-manager: ## Deploy: Deploy Fund Manager contract
	@echo "💰 Deploying Fund Manager contract..."
	@echo "   📍 Network: Fluent Devnet"
	gblend deploy contracts/FundManager.sol --network fluent
	@echo "✅ Fund Manager deployed!"
	@echo "📋 Copy the deployed address to .env as FUND_MANAGER_ADDRESS"

deploy-tournament: ## Deploy: Deploy Tournament contract (requires other contracts)
	@echo "🎮 Deploying Tournament contract..."
	@if [ -z "$(ORACLE_ADDRESS)" ] || [ -z "$(COMPUTER_AI_ADDRESS)" ] || [ -z "$(FUND_MANAGER_ADDRESS)" ]; then \
		echo "❌ Error: Missing contract addresses in .env"; \
		echo "   Please deploy other contracts first and update .env"; \
		echo "   Required: ORACLE_ADDRESS, COMPUTER_AI_ADDRESS, FUND_MANAGER_ADDRESS"; \
		exit 1; \
	fi
	@echo "   📍 Network: Fluent Devnet"
	@echo "   🔗 Oracle: $(ORACLE_ADDRESS)"
	@echo "   🤖 Computer AI: $(COMPUTER_AI_ADDRESS)"
	@echo "   💰 Fund Manager: $(FUND_MANAGER_ADDRESS)"
	gblend deploy contracts/RPSTournament.sol --constructor-args $(ORACLE_ADDRESS) $(COMPUTER_AI_ADDRESS) $(FUND_MANAGER_ADDRESS) --network fluent
	@echo "✅ Tournament deployed!"
	@echo "📋 Copy the deployed address to .env as TOURNAMENT_ADDRESS"

deploy-contracts: ## Deploy: Deploy contracts in correct order (interactive)
	@echo "🚀 Starting contract deployment process..."
	@echo ""
	@echo "📋 Deployment Steps:"
	@echo "   1. Deploy Oracle"
	@echo "   2. Deploy Computer AI"  
	@echo "   3. Deploy Fund Manager"
	@echo "   4. Deploy Tournament (uses addresses from steps 1-3)"
	@echo ""
	@echo "🔮 Step 1: Deploying Oracle..."
	make deploy-oracle
	@echo ""
	@read -p "📝 Please update ORACLE_ADDRESS in .env and press Enter to continue..." dummy
	@echo "🤖 Step 2: Deploying Computer AI..."
	make deploy-computer-ai
	@echo ""
	@read -p "📝 Please update COMPUTER_AI_ADDRESS in .env and press Enter to continue..." dummy
	@echo "💰 Step 3: Deploying Fund Manager..."
	make deploy-fund-manager
	@echo ""
	@read -p "📝 Please update FUND_MANAGER_ADDRESS in .env and press Enter to continue..." dummy
	@echo "🎮 Step 4: Deploying Tournament..."
	make deploy-tournament
	@echo ""
	@echo "🎉 All contracts deployed!"
	@echo "📝 Don't forget to:"
	@echo "   - Update TOURNAMENT_ADDRESS in .env"
	@echo "   - Update contract addresses in frontend/src/utils/constants.ts"
	@echo "   - Fund the computer with: make setup-computer-funds"

setup-computer-funds: ## Deploy: Setup computer funds for betting
	@if [ -z "$(FUND_MANAGER_ADDRESS)" ]; then \
		echo "❌ Error: FUND_MANAGER_ADDRESS not set in .env"; \
		exit 1; \
	fi
	@echo "💰 Setting up computer betting funds..."
	@echo "   📍 Fund Manager: $(FUND_MANAGER_ADDRESS)"
	@echo "   💸 Depositing 0.1 ETH for computer betting..."
	gblend call $(FUND_MANAGER_ADDRESS) "depositFunds()" --value 100000000000000000 --network fluent
	@if [ ! -z "$(TOURNAMENT_ADDRESS)" ]; then \
		echo "   🔗 Setting tournament contract address..."; \
		gblend call $(FUND_MANAGER_ADDRESS) "setGameContract(address)" --args $(TOURNAMENT_ADDRESS) --network fluent; \
	fi
	@echo "✅ Computer funds setup complete!"

# Development
dev: ## Development: Start frontend development server
	@echo "⚛️  Starting frontend development server..."
	@echo "   🌐 URL: http://localhost:3000"
	cd frontend && npm run dev

dev-build: ## Development: Build and start everything for development
	make build-all
	make dev

test-rust: ## Development: Run Rust tests
	@echo "🧪 Running Rust tests..."
	cd rust-oracle && cargo test
	cd rust-computer-ai && cargo test

test-game: ## Development: Test game functionality (requires deployed contracts)
	@if [ -z "$(TOURNAMENT_ADDRESS)" ]; then \
		echo "❌ Error: TOURNAMENT_ADDRESS not set in .env"; \
		exit 1; \
	fi
	@echo "🎮 Testing game functionality..."
	@echo "   💰 Starting game with 0.001 ETH bet..."
	gblend call $(TOURNAMENT_ADDRESS) "startGame()" --value 1000000000000000 --network fluent
	@echo "   🪨 Playing Rock..."
	gblend call $(TOURNAMENT_ADDRESS) "playRound(uint8)" --args 0 --network fluent
	@echo "✅ Game test complete! Check transaction results."

info: ## Development: Show project information
	@echo "Cross-VM Rock-Paper-Scissors Tournament"
	@echo "======================================="
	@echo ""
	@echo "📁 Project Structure:"
	@echo "   🦀 rust-oracle/         - Pure randomness generation"
	@echo "   🤖 rust-computer-ai/    - Computer AI decision making"
	@echo "   📜 contracts/           - Solidity contracts"
	@echo "   ⚛️  frontend/            - React frontend"
	@echo ""
	@echo "🌐 Network Info:"
	@echo "   🔗 Network: Fluent Devnet"
	@echo "   🌐 RPC: https://rpc.dev.gblend.xyz/"
	@echo "   🆔 Chain ID: 20993"
	@echo "   🔍 Explorer: https://blockscout.dev.gblend.xyz/"
	@echo "   💰 Faucet: https://faucet.dev.gblend.xyz/"
	@echo ""
	@echo "🏗️ Architecture:"
	@echo "   1. Oracle (Rust) → Random number generation"
	@echo "   2. Computer AI (Rust) → Game strategy & betting"
	@echo "   3. Fund Manager (Solidity) → Computer's funds"
	@echo "   4. Tournament (Solidity) → Game logic & payouts"
	@echo "   5. Frontend (React) → User interface"

clean: ## Development: Clean all build artifacts
	@echo "🧹 Cleaning build artifacts..."
	@echo "   🦀 Cleaning Rust artifacts..."
	cd rust-oracle && cargo clean
	cd rust-computer-ai && cargo clean
	@echo "   ⚛️  Cleaning frontend artifacts..."
	cd frontend && rm -rf dist node_modules/.vite .parcel-cache 2>/dev/null || true
	@echo "✅ Clean complete!"

clean-all: clean ## Development: Clean everything including node_modules
	@echo "🧹 Deep cleaning..."
	cd frontend && rm -rf node_modules 2>/dev/null || true
	@echo "✅ Deep clean complete!"

# Quick deployment for testing
deploy-all: ## Deploy: Quick deploy all contracts (non-interactive)
	@echo "⚡ Quick deployment mode - make sure you have addresses ready to update!"
	make deploy-oracle
	make deploy-computer-ai
	make deploy-fund-manager
	@echo ""
	@echo "⏸️  Pausing for manual address updates..."
	@echo "📝 Please update .env with the deployed contract addresses, then run:"
	@echo "   make deploy-tournament"
	@echo "   make setup-computer-funds"
