#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate alloc;

use alloc::vec::Vec;
use fluentbase_sdk::{
    basic_entrypoint,
    derive::{router, Contract},
    SharedAPI, U256,
};

/**
 * @title ComputerAI  
 * @notice Strategic AI for Rock-Paper-Scissors with pattern detection and adaptive betting
 * @dev Implements betting strategy and move selection algorithms with pattern recognition
 * @author rakshithvk19
 * @custom:security AI decisions are deterministic based on game state and randomness
 */
#[derive(Contract)]
struct ComputerAI<SDK> {
    sdk: SDK,
}

/**
 * @title ComputerAIAPI
 * @notice Interface for computer AI decision making in Rock-Paper-Scissors
 */
pub trait ComputerAIAPI {
    /**
     * @notice Get computer's move for current round
     * @param round Current round number (0-indexed)
     * @param seed Game seed for consistency and randomness
     * @param player_history Array of player's previous moves (0=Rock, 1=Paper, 2=Scissors)
     * @return move Computer's move choice (0=Rock, 1=Paper, 2=Scissors)
     */
    fn get_move(&self, round: U256, seed: U256, player_history: Vec<U256>) -> U256;

    /**
     * @notice Get computer's betting recommendation based on game analysis
     * @param player_wins Player's current wins in the game
     * @param computer_wins Computer's current wins in the game  
     * @param total_rounds Total number of rounds in this game
     * @param current_round Current round number (0-indexed)
     * @return bet_amount Suggested bet amount in wei
     */
    fn get_betting_advice(
        &self,
        player_wins: U256,
        computer_wins: U256,
        total_rounds: U256,
        current_round: U256,
    ) -> U256;

    /**
     * @notice Get AI difficulty level
     * @return difficulty Difficulty level (0=Easy, 1=Medium, 2=Hard)
     */
    fn get_difficulty(&self) -> U256;
}

#[router(mode = "solidity")]
impl<SDK: SharedAPI> ComputerAIAPI for ComputerAI<SDK> {
    #[function_id("get_move(uint256,uint256,uint256[])")]
    fn get_move(&self, round: U256, seed: U256, player_history: Vec<U256>) -> U256 {
        // Create base randomness from round and seed
        let random_factor = seed
            .wrapping_add(round.wrapping_mul(U256::from(7)))  // Round-based variation
            .wrapping_mul(U256::from(7919))                   // Prime multiplication
            ^ U256::from(54321); // XOR for mixing

        // Strategic pattern detection
        if !player_history.is_empty() {
            let last_move = player_history[player_history.len() - 1];

            // Counter-strategy: 40% chance to beat last move
            if (random_factor % U256::from(10)) < U256::from(4) {
                // Rock(0)->Paper(1), Paper(1)->Scissors(2), Scissors(2)->Rock(0)
                return (last_move + U256::from(1)) % U256::from(3);
            }

            // Repetition detection: counter repeated moves
            if player_history.len() >= 2 {
                let second_last = player_history[player_history.len() - 2];
                if last_move == second_last && (random_factor % U256::from(10)) < U256::from(3) {
                    return (last_move + U256::from(1)) % U256::from(3);
                }
            }
        }

        // Default random move
        random_factor % U256::from(3)
    }

    #[function_id("get_betting_advice(uint256,uint256,uint256,uint256)")]
    fn get_betting_advice(
        &self,
        player_wins: U256,
        computer_wins: U256,
        _total_rounds: U256,
        current_round: U256,
    ) -> U256 {
        // Base betting amount: 0.001 ETH
        let base_bet = U256::from(1000000000000000u64);
        let total_played = player_wins + computer_wins;

        // Initial game strategy
        if total_played == U256::from(0) {
            return base_bet;
        }

        // Aggressive strategy when winning
        if computer_wins > player_wins {
            let advantage = computer_wins - player_wins;
            let multiplier = U256::from(1)
                + (advantage * U256::from(2) / U256::max(total_played, U256::from(1)));
            let capped_multiplier = if multiplier > U256::from(3) {
                U256::from(3)
            } else {
                multiplier
            };
            return base_bet * capped_multiplier;
        }

        // Conservative strategy when losing
        if player_wins > computer_wins {
            return base_bet / U256::from(2);
        }

        // Even game: add slight variation
        let variation = (current_round % U256::from(20)) + U256::from(90); // 90-110%
        base_bet * variation / U256::from(100)
    }

    #[function_id("get_difficulty()")]
    fn get_difficulty(&self) -> U256 {
        U256::from(1) // Medium difficulty
    }
}

impl<SDK: SharedAPI> ComputerAI<SDK> {
    /**
     * @notice Contract deployment initialization
     * @dev Called once during contract deployment
     */
    fn deploy(&mut self) {
        // AI parameters could be initialized here if needed
    }
}

basic_entrypoint!(ComputerAI);
