#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate alloc;

use fluentbase_sdk::{
    basic_entrypoint,
    derive::{router, Contract},
    SharedAPI, 
    U256,
    ContextReader,  
};

/**
 * @title RandomOracle
 * @notice Provides deterministic randomness generation for blockchain gaming applications
 * @dev Uses block timestamp and block number as entropy sources combined with mathematical mixing
 * @author rakshithvk19
 * @custom:security Randomness is suitable for gaming but not cryptographically secure
 */
#[derive(Contract)]
struct RandomOracle<SDK> {
    sdk: SDK,
}

/**
 * @title RandomOracleAPI
 * @notice Interface defining randomness generation functions
 */
pub trait RandomOracleAPI {
    /**
     * @notice Generates number of tournament rounds based on seed
     * @param seed Entropy source for deterministic generation
     * @return rounds Number of rounds between 1 and 10 inclusive
     */
    fn generate_rounds(&self, seed: U256) -> U256;

    /**
     * @notice Generates random number within specified range
     * @param seed Entropy source for deterministic generation
     * @param range Upper bound (exclusive), must be greater than 0
     * @return number Random number between 0 and range-1 inclusive
     */
    fn get_random_number(&self, seed: U256, range: U256) -> U256;

    /**
     * @notice Generates pseudo-random seed using current blockchain state
     * @dev Combines block timestamp and number with mathematical operations
     * @return seed Pseudo-random value for use in other functions
     */
    fn get_random_seed(&self) -> U256;
}

#[router(mode = "solidity")]
impl<SDK: SharedAPI> RandomOracleAPI for RandomOracle<SDK> {
    #[function_id("generate_rounds(uint256)")]
    fn generate_rounds(&self, seed: U256) -> U256 {
        // Apply mathematical transformations for uniform distribution
        let mixed = seed
            .wrapping_mul(U256::from(7919))    // Prime multiplication
            .wrapping_add(U256::from(12345))   // Additive constant
            ^ U256::from(54321); // XOR for bit mixing

        // Map to range [1, 10] for tournament rounds
        (mixed % U256::from(10)) + U256::from(1)
    }

    #[function_id("get_random_number(uint256,uint256)")]
    fn get_random_number(&self, seed: U256, range: U256) -> U256 {
        // Handle edge case of zero range
        if range == U256::from(0) {
            return U256::from(0);
        }

        // Apply transformations for better distribution
        let mixed = seed
            .wrapping_add(U256::from(67890))   // Offset
            .wrapping_mul(U256::from(6151))    // Prime multiplication
            ^ U256::from(9876); // XOR mixing

        mixed % range
    }

    #[function_id("get_random_seed()")]
    fn get_random_seed(&self) -> U256 {
        // Obtain blockchain state for entropy
        let context = self.sdk.context();
        let block_timestamp = U256::from(context.block_timestamp());
        let block_number = U256::from(context.block_number());

        // Primary entropy combination
        let primary_entropy = block_timestamp
            .wrapping_mul(block_number)                    // Temporal * sequential entropy
            .wrapping_add(U256::from(31337))               // Mixing constant
            ^ block_number.wrapping_add(U256::from(42)); // Additional block-based mixing

        // Secondary mixing for enhanced distribution
        primary_entropy
            .wrapping_mul(U256::from(6151))     // Prime multiplication
            .wrapping_add(block_timestamp)      // Reintroduce temporal component  
            ^ U256::from(13579) // Final XOR mixing
    }
}

impl<SDK: SharedAPI> RandomOracle<SDK> {
    /**
     * @notice Contract deployment initialization
     * @dev Called once during contract deployment - no state to initialize
     */
    fn deploy(&mut self) {
        // No initialization required for stateless Oracle
    }
}

basic_entrypoint!(RandomOracle);
