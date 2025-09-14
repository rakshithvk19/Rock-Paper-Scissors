#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate alloc;

use alloc::vec::Vec;
use fluentbase_sdk::{
    basic_entrypoint,
    derive::{router, Contract},
    SharedAPI,
    U256,
};

/// Computer AI for Rock-Paper-Scissors decision making
#[derive(Contract)]
struct ComputerAI<SDK> {
    sdk: SDK,
}

/// API for computer AI decision making
pub trait ComputerAIAPI {
    /// Get computer's move for current round
    fn get_move(&self, round: U256, seed: U256, player_history: Vec<U256>) -> U256;
    
    /// Get computer's betting recommendation  
    fn get_betting_advice(&self, player_wins: U256, computer_wins: U256, total_rounds: U256, current_round: U256) -> U256;
    
    /// Get AI difficulty level
    fn get_difficulty(&self) -> U256;
}

#[router(mode = "solidity")]
impl<SDK: SharedAPI> ComputerAIAPI for ComputerAI<SDK> {
    fn get_move(&self, round: U256, seed: U256, player_history: Vec<U256>) -> U256 {
        let block_number = self.sdk.block_number();
        let block_timestamp = self.sdk.block_timestamp();
        
        // Simple strategy: mix randomness with basic pattern detection
        let mut random_factor = block_number
            .wrapping_add(block_timestamp)
            .wrapping_add(seed)
            .wrapping_add(round);
            
        // If we have player history, add some basic counter-strategy
        if !player_history.is_empty() {
            let last_move = player_history[player_history.len() - 1];
            
            // Simple counter-strategy: 30% chance to counter the last move
            if (random_factor % U256::from(10)) < U256::from(3) {
                // Counter the last move: Rock->Paper, Paper->Scissors, Scissors->Rock
                return (last_move + U256::from(1)) % U256::from(3);
            }
        }
        
        // Otherwise, return random move (0=Rock, 1=Paper, 2=Scissors)
        random_factor % U256::from(3)
    }
    
    fn get_betting_advice(&self, player_wins: U256, computer_wins: U256, total_rounds: U256, current_round: U256) -> U256 {
        // Base bet: 0.001 ETH (1000000000000000 wei)
        let base_bet = U256::from(1000000000000000u64);
        
        let block_timestamp = self.sdk.block_timestamp();
        
        // Calculate win percentage
        let total_played = player_wins + computer_wins;
        
        if total_played == U256::from(0) {
            return base_bet; // First round, bet base amount
        }
        
        // If computer is winning, bet more (up to 3x)
        if computer_wins > player_wins {
            let advantage = computer_wins - player_wins;
            let multiplier = U256::from(1) + (advantage * U256::from(2) / total_played);
            let max_multiplier = U256::from(3);
            let final_multiplier = if multiplier > max_multiplier { max_multiplier } else { multiplier };
            return base_bet * final_multiplier;
        }
        
        // If computer is losing, bet conservatively (0.5x to 1x)
        if player_wins > computer_wins {
            return base_bet / U256::from(2);
        }
        
        // If tied, bet base amount with slight randomness
        let random_factor = (block_timestamp % U256::from(20)) + U256::from(90); // 90-110%
        base_bet * random_factor / U256::from(100)
    }
    
    fn get_difficulty(&self) -> U256 {
        // Return 1 for Medium difficulty
        U256::from(1)
    }
}

basic_entrypoint!(ComputerAI);
