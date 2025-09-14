# Makefile for Cross-VM Rock-Paper-Scissors Tournament (Pure gblend)

-include .env

.PHONY: help install build deploy clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install gblend and dependencies
	@echo "Installing gblend CLI..."
	cargo install gblend
	@echo "Installing Rust dependencies..."
	cd rust-oracle && cargo build

build-rust: ## Build Rust Oracle
	@echo "Building Rust Oracle..."
	cd rust-oracle && cargo build --release --target wasm32-unknown-unknown
	@echo "WASM built at: rust-oracle/target/wasm32-unknown-unknown/release/rps_oracle.wasm"

build-solidity: ## Build Solidity contracts with gblend
	@echo "Building Solidity contracts..."
	gblend build sol

build: build-rust build-solidity ## Build all contracts

deploy-oracle: ## Deploy Rust Oracle using gblend
	@echo "Deploying Rust Oracle to Fluent testnet..."
	cd rust-oracle && gblend deploy --network fluent
	@echo "Update ORACLE_ADDRESS in .env with the deployed address"

deploy-game: ## Deploy Game contract using gblend
	@echo "Deploying RPSTournament to Fluent testnet..."
	gblend deploy contracts/RPSTournament.sol --network fluent

deploy: ## Deploy all contracts
	@echo "Starting deployment process..."
	make deploy-oracle
	@echo "Please update ORACLE_ADDRESS in .env, then run: make deploy-game"

clean: ## Clean build artifacts
	@echo "Cleaning Rust artifacts..."
	cd rust-oracle && cargo clean
	@echo "Clean complete"

# Development commands
dev-setup: ## Setup development environment
	@echo "Setting up development environment..."
	cp .env.example .env
	@echo "Please edit .env with your private key"
	make install
	make build

# Fluent-specific commands
get-faucet: ## Get testnet tokens
	@echo "Visit: https://faucet.dev.gblend.xyz/"
	@echo "Enter your address to get testnet tokens"

# gblend commands
init-blended: ## Initialize a new blended app with gblend
	gblend init
	@echo "Choose 'Blended app' for cross-VM development"

# Testing (minimal without Foundry)
test-rust: ## Run Rust tests
	cd rust-oracle && cargo test

# Info commands
info: ## Show project information
	@echo "Cross-VM Rock-Paper-Scissors Tournament"
	@echo "========================================="
	@echo "Rust Oracle: rust-oracle/"
	@echo "Solidity Game: contracts/RPSTournament.sol"
	@echo ""
	@echo "Network: Fluent Testnet"
	@echo "RPC: https://rpc.dev.gblend.xyz/"
	@echo "Chain ID: 20993"
	@echo "Explorer: https://blockscout.dev.gblend.xyz/"