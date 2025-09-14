# 📋 Deployment Checklist for Fluent Testnet (Pure gblend)

Follow this step-by-step guide to deploy your Cross-VM Rock-Paper-Scissors Tournament using gblend.

## Pre-Deployment

- [ ] Install all prerequisites
  ```bash
  # Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  
  # gblend CLI
  cargo install gblend
  
  # WASM target
  rustup target add wasm32-unknown-unknown
  ```

- [ ] Clone and setup repository
  ```bash
  git clone <your-repo>
  cd Cross-VM-Rock-Paper-Scissors
  ```

- [ ] Configure environment
  ```bash
  cp .env.example .env
  # Edit .env with your private key
  ```

- [ ] Get testnet tokens
  - Visit: https://faucet.dev.gblend.xyz/
  - Request tokens for your wallet address

## Build Phase

- [ ] Build Rust Oracle
  ```bash
  cd rust-oracle
  cargo build --release --target wasm32-unknown-unknown
  cd ..
  ```

- [ ] Build Solidity contracts
  ```bash
  gblend build sol
  ```

## Deployment Phase

### Step 1: Deploy Rust Oracle

- [ ] Deploy using gblend
  ```bash
  cd rust-oracle
  gblend deploy --network fluent
  ```

- [ ] Note the deployed address
  ```
  Oracle Address: 0x...
  ```

- [ ] Update .env file
  ```bash
  ORACLE_ADDRESS=<deployed_oracle_address>
  ```

### Step 2: Deploy Tournament Contract

- [ ] Deploy using gblend
  ```bash
  gblend deploy contracts/RPSTournament.sol --network fluent --constructor-args <ORACLE_ADDRESS>
  ```

- [ ] Note the deployed address
  ```
  Tournament Address: 0x...
  ```

- [ ] Update .env file
  ```bash
  TOURNAMENT_ADDRESS=<deployed_tournament_address>
  ```

## Verification Phase

- [ ] Verify on block explorer
  - Oracle: https://blockscout.dev.gblend.xyz/address/<ORACLE_ADDRESS>
  - Tournament: https://blockscout.dev.gblend.xyz/address/<TOURNAMENT_ADDRESS>

- [ ] Test cross-VM communication
  ```bash
  # Start a tournament
  gblend call RPSTournament startTournament --network fluent
  
  # Play a round
  gblend call RPSTournament playRound 0 --network fluent
  ```

## Testing the Game

- [ ] Start a new tournament
  ```bash
  gblend call RPSTournament startTournament --network fluent
  ```

- [ ] Check tournament status
  ```bash
  gblend call RPSTournament getTournamentStatus <YOUR_ADDRESS> --network fluent
  ```

- [ ] Play rounds (0=Rock, 1=Paper, 2=Scissors)
  ```bash
  gblend call RPSTournament playRound 0 --network fluent
  gblend call RPSTournament playRound 1 --network fluent
  gblend call RPSTournament playRound 2 --network fluent
  ```

## Documentation Phase

- [ ] Document deployment addresses
- [ ] Take screenshots of:
  - [ ] Deployment transactions
  - [ ] Contract on explorer
  - [ ] Game being played
  - [ ] Cross-VM calls in action

- [ ] Write blog post covering:
  - [ ] Pure gblend workflow
  - [ ] Cross-VM communication
  - [ ] Gas efficiency
  - [ ] Developer experience

## Troubleshooting

### Common Issues & Solutions

1. **gblend not found**
   ```bash
   export PATH="$HOME/.cargo/bin:$PATH"
   ```

2. **WASM build fails**
   ```bash
   rustup target add wasm32-unknown-unknown
   cargo clean
   cargo build --release --target wasm32-unknown-unknown
   ```

3. **Insufficient funds**
   - Get more testnet tokens from faucet
   - Check balance: `gblend balance --network fluent`

4. **Oracle deployment fails**
   - Ensure WASM file exists and is optimized
   - Check file size (should be < 24KB after optimization)

5. **Cross-VM calls fail**
   - Verify oracle address is correct in constructor args
   - Check oracle contract is deployed and verified
   - Ensure function signatures match between Rust and Solidity

## Success Metrics

- ✅ Both contracts deployed successfully
- ✅ Cross-VM calls working (3+ successful calls)
- ✅ Game playable from start to finish
- ✅ Gas costs reasonable (<50k per round)
- ✅ Events emitting correctly
- ✅ Explorer showing all transactions

## gblend Commands Reference

```bash
# Build commands
gblend build rust         # Build Rust contract
gblend build sol          # Build Solidity contract

# Deploy commands
gblend deploy <path>      # Deploy contract
gblend deploy --network fluent --constructor-args <args>

# Interaction commands
gblend call <contract> <function> <args> --network fluent
gblend send <contract> <function> <args> --network fluent

# Query commands
gblend balance --network fluent
gblend tx <hash> --network fluent
```

## Next Steps

After successful deployment:

1. **Test thoroughly**
   - Play multiple games
   - Test edge cases
   - Verify gas costs

2. **Share your work**
   - Create demo video
   - Write technical blog post
   - Share on social media

3. **Engage with Fluent**
   - Join their Discord
   - Share in #showcase channel
   - Report any bugs or suggestions

---

**Remember**: Using pure gblend demonstrates your commitment to Fluent's ecosystem and tooling!