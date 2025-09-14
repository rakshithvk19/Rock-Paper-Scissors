#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate alloc;

use alloc::vec::Vec;
use fluentbase_sdk::{
    basic_entrypoint,
    derive::{router, Contract},
    SharedAPI,
    U256,
};

/// Random Oracle for Rock-Paper-Scissors Tournament
/// Provides randomness and game logic for cross-VM gameplay
#[derive(Contract)]
struct RandomOracle<SDK> {
    sdk: SDK,
}

/// Public API for the Random Oracle
/// These functions are callable from Solidity contracts
pub trait RandomOracleAPI {
    /// Generate number of rounds for a tournament (3, 5, or 7)
    fn generate_rounds(&self, seed: U256) -> U256;
    
    /// Get computer's choice for a specific round
    fn get_rps_choice(&self, round: U256, seed: U256) -> U256;
    
    /// Check who wins a single round
    fn check_round_winner(&self, player_move: U256, computer_move: U256) -> U256;
    
    /// Determine the overall tournament champion
    fn determine_champion(&self, player_wins: U256, computer_wins: U256, total_rounds: U256) -> U256;
    
    /// Get the majority threshold for winning
    fn get_majority_threshold(&self, total_rounds: U256) -> U256;
}

#[router(mode = "solidity")]
impl<SDK: SharedAPI> RandomOracleAPI for RandomOracle<SDK> {
    fn generate_rounds(&self, seed: U256) -> U256 {
        // Generate odd number of rounds to prevent ties
        let block_number = self.sdk.block_number();
        let block_timestamp = self.sdk.block_timestamp();
        
        // Mix block data with seed for randomness
        let mixed = block_number
            .wrapping_add(block_timestamp)
            .wrapping_mul(seed.wrapping_add(U256::from(1)));
        
        // Generate 0, 1, or 2, then map to 3, 5, or 7 rounds
        let random_index = mixed % U256::from(3);
        
        match random_index.as_u32() {
            0 => U256::from(3),  // Best of 3
            1 => U256::from(5),  // Best of 5
            _ => U256::from(7),  // Best of 7
        }
    }
    
    fn get_rps_choice(&self, round: U256, seed: U256) -> U256 {
        // Generate computer's move for a specific round
        let block_number = self.sdk.block_number();
        let block_timestamp = self.sdk.block_timestamp();
        
        // Mix round number into randomness for variety across rounds
        let mixed = block_number
            .wrapping_add(block_timestamp)
            .wrapping_mul(seed.wrapping_add(round).wrapping_add(U256::from(1)));
        
        // Return 0 (Rock), 1 (Paper), or 2 (Scissors)
        mixed % U256::from(3)
    }
    
    fn check_round_winner(&self, player_move: U256, computer_move: U256) -> U256 {
        // Determine round winner
        // Rock = 0, Paper = 1, Scissors = 2
        // Returns: 0 = draw, 1 = player wins, 2 = computer wins
        
        if player_move == computer_move {
            return U256::from(0); // Draw
        }
        
        // Check winning conditions using game rules
        // Rock (0) beats Scissors (2)
        // Paper (1) beats Rock (0)
        // Scissors (2) beats Paper (1)
        let player_wins = match (player_move.as_u32(), computer_move.as_u32()) {
            (0, 2) => true, // Rock beats Scissors
            (1, 0) => true, // Paper beats Rock
            (2, 1) => true, // Scissors beats Paper
            _ => false,
        };
        
        if player_wins {
            U256::from(1) // Player wins this round
        } else {
            U256::from(2) // Computer wins this round
        }
    }
    
    fn determine_champion(&self, player_wins: U256, computer_wins: U256, total_rounds: U256) -> U256 {
        // Determine tournament champion based on majority wins
        let majority = self.get_majority_threshold(total_rounds);
        
        if player_wins >= majority {
            U256::from(1) // Player is champion
        } else if computer_wins >= majority {
            U256::from(2) // Computer is champion
        } else {
            U256::from(0) // Tournament still ongoing or error
        }
    }
    
    fn get_majority_threshold(&self, total_rounds: U256) -> U256 {
        // Calculate majority (more than half of total rounds)
        (total_rounds / U256::from(2)) + U256::from(1)
    }
}

// Entry point for the WASM contract
basic_entrypoint!(RandomOracle);