# Cross-VM Rock-Paper-Scissors Deployment
-include .env

.PHONY: install deploy-oracle deploy-computer-ai deploy-fund-manager deploy-tournament game-setup start-frontend

install:
	@echo "Installing gblend and foundry..."
	cargo install gblend
	@echo "Installing foundry (for Solidity deployment)..."
	curl -L https://foundry.paradigm.xyz | bash
	@echo "❗ IMPORTANT: Run 'foundryup' in a new terminal to complete foundry installation"
	@echo "❗ Then restart your terminal before deploying Solidity contracts"

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
	@echo "Deploying Fund Manager with 0.02 ETH funding..."
	@if [ -z "$(DEPLOYER_PRIVATE_KEY)" ]; then \
		echo "❌ Error: DEPLOYER_PRIVATE_KEY not set in .env"; \
		exit 1; \
	fi
	forge create contracts/FundManager.sol:FundManager \
		--private-key $(DEPLOYER_PRIVATE_KEY) \
		--rpc-url $(FLUENT_DEVNET_RPC) \
		--broadcast \
		--value 0.02ether
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

game-setup:
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
	@echo -n "export const FundManagerABI = " > frontend/src/contracts/FundManager.ts
	forge inspect contracts/FundManager.sol:FundManager abi --json | tr -d '\n' >> frontend/src/contracts/FundManager.ts
	@echo " as const;" >> frontend/src/contracts/FundManager.ts
	@echo "Fund Manager ABI generated in frontend/src/contracts/FundManager.ts"

generate-tournament-abi:
	@echo "Generating Tournament ABI..."
	@echo -n "export const RPSTournamentABI = " > frontend/src/contracts/RPSTournament.ts
	forge inspect contracts/RPSTournament.sol:RPSTournament abi --json | tr -d '\n' >> frontend/src/contracts/RPSTournament.ts
	@echo " as const;" >> frontend/src/contracts/RPSTournament.ts
	@echo "Tournament ABI generated in frontend/src/contracts/RPSTournament.ts"

generate-abis: generate-fund-manager-abi generate-tournament-abi
	@echo "All ABIs generated successfully"