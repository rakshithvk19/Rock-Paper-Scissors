# Cross-VM Rock-Paper-Scissors Deployment
-include .env

.PHONY: help install get-devnet-tokens deploy-oracle deploy-computer-ai deploy-fund-manager deploy-tournament fund-computer setup-game-contract start-frontend stop-frontend

help:
	@echo "Cross-VM RPS Deployment"
	@echo "======================="
	@echo "install              Install gblend CLI and Foundry"
	@echo "get-devnet-tokens    Get devnet ETH from faucet"
	@echo "deploy-oracle        Deploy Oracle contract (Rust/WASM) to Fluent Devnet"
	@echo "deploy-computer-ai   Deploy Computer AI contract (Rust/WASM) to Fluent Devnet" 
	@echo "deploy-fund-manager  Deploy Fund Manager contract (Solidity) to Fluent Devnet"
	@echo "deploy-tournament    Deploy Tournament contract (Solidity) to Fluent Devnet"
	@echo "fund-computer        Fund computer with 0.02 ETH for betting"
	@echo "setup-game-contract  Set tournament address in Fund Manager"
	@echo "start-frontend       Start React development server on localhost:3000"
	@echo ""
	@echo "Network: Fluent Devnet (Chain ID: 20993) - Lower gas fees"
	@echo "RPC: https://rpc.dev.gblend.xyz"
	@echo "Explorer: https://blockscout.dev.gblend.xyz"
	@echo "Faucet: https://faucet.dev.gblend.xyz"
	@echo ""
	@echo "Tools: gblend (Rust) + forge (Solidity) + cast (contract calls)"
	@echo "Requires: DEPLOYER_PRIVATE_KEY in .env"

install:
	@echo "Installing gblend and foundry..."
	cargo install gblend
	@echo "Installing foundry (for Solidity deployment)..."
	curl -L https://foundry.paradigm.xyz | bash
	@echo "❗ IMPORTANT: Run 'foundryup' in a new terminal to complete foundry installation"
	@echo "❗ Then restart your terminal before deploying Solidity contracts"

get-devnet-tokens:
	@echo "💰 Get Fluent Devnet tokens:"
	@echo "   🌐 Visit: https://faucet.dev.gblend.xyz/"
	@echo "   📋 Enter your wallet address to get devnet ETH"
	@echo "   💡 Devnet has much lower gas fees than testnet"

deploy-oracle:
	@echo "Deploying Oracle to Fluent Devnet..."
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "❌ Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	cd rust-oracle && gblend build rust && gblend deploy --rpc $(FLUENT_DEVNET_RPC) --chain-id $(FLUENT_DEVNET_CHAIN_ID) --private-key $(DEPLOYER_PRIVATE_KEY) lib.wasm
	@echo "Update ORACLE_ADDRESS in .env with the deployed address"

deploy-computer-ai:
	@echo "Deploying Computer AI to Fluent Devnet..."
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "❌ Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	cd rust-computer-ai && gblend build rust && gblend deploy --rpc $(FLUENT_DEVNET_RPC) --chain-id $(FLUENT_DEVNET_CHAIN_ID) --private-key $(DEPLOYER_PRIVATE_KEY) lib.wasm
	@echo "Update COMPUTER_AI_ADDRESS in .env with the deployed address"

deploy-fund-manager:
	@echo "Deploying Fund Manager to Fluent Devnet..."
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "❌ Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	forge create contracts/FundManager.sol:FundManager \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		--rpc-url $(FLUENT_DEVNET_RPC) \
		--broadcast 
	@echo "Update FUND_MANAGER_ADDRESS in .env with the deployed address"

deploy-tournament:
	@echo "Deploying Tournament to Fluent Devnet..."
	@if [ -z "$(ORACLE_ADDRESS)" ] || [ -z "$(COMPUTER_AI_ADDRESS)" ] || [ -z "$(FUND_MANAGER_ADDRESS)" ]; then \
		echo "Error: Set ORACLE_ADDRESS, COMPUTER_AI_ADDRESS, and FUND_MANAGER_ADDRESS in .env first"; \
		exit 1; \
	fi
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "❌ Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	forge create contracts/RPSTournament.sol:RPSTournament \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		--rpc-url $(FLUENT_DEVNET_RPC) \
		--broadcast \
		--constructor-args $(ORACLE_ADDRESS) $(COMPUTER_AI_ADDRESS) $(FUND_MANAGER_ADDRESS) 
	@echo "Update TOURNAMENT_ADDRESS in .env with the deployed address"

fund-computer:
	@echo "Funding computer with 0.02 ETH..."
	@if [ -z "$(FUND_MANAGER_ADDRESS)" ]; then \
		echo "Error: Set FUND_MANAGER_ADDRESS in .env first"; \
		exit 1; \
	fi
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	cast send $(FUND_MANAGER_ADDRESS) "depositFunds()" \
		--value 0.02ether \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		--rpc-url $(FLUENT_DEVNET_RPC)
	@echo "Computer funded with 0.02 ETH successfully"

setup-game-contract:
	@echo "Setting tournament contract in Fund Manager..."
	@if [ -z "$(FUND_MANAGER_ADDRESS)" ] || [ -z "$(TOURNAMENT_ADDRESS)" ]; then \
		echo "Error: Set FUND_MANAGER_ADDRESS and TOURNAMENT_ADDRESS in .env first"; \
		exit 1; \
	fi
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	cast send $(FUND_MANAGER_ADDRESS) "setGameContract(address)" $(TOURNAMENT_ADDRESS) \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		--rpc-url $(FLUENT_DEVNET_RPC)
	@echo "Tournament contract set in Fund Manager"

start-frontend:
	@echo "Starting frontend development server..."
	@echo "URL: http://localhost:3000"
	cd frontend && npm run dev

generate-fund-manager-abi:
	@echo "Generating Fund Manager ABI..."
	@echo "export const FundManagerABI = " > frontend/src/contracts/FundManager.ts
	forge inspect contracts/FundManager.sol:FundManager abi --json >> frontend/src/contracts/FundManager.ts
	@echo " as const;" >> frontend/src/contracts/FundManager.ts
	@echo "Fund Manager ABI generated in frontend/src/contracts/FundManager.ts"

generate-tournament-abi:
	@echo "Generating Tournament ABI..."
	@echo "export const RPSTournamentABI = " > frontend/src/contracts/RPSTournament.ts
	forge inspect contracts/RPSTournament.sol:RPSTournament abi --json >> frontend/src/contracts/RPSTournament.ts
	@echo " as const;" >> frontend/src/contracts/RPSTournament.ts
	@echo "Tournament ABI generated in frontend/src/contracts/RPSTournament.ts"

generate-abis: generate-fund-manager-abi generate-tournament-abi
	@echo "All ABIs generated successfully"