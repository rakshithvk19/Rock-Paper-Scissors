#![cfg_attr(target_arch = "wasm32", no_std)]
extern crate alloc;

use fluentbase_sdk::{
    basic_entrypoint,
    derive::{router, Contract},
    SharedAPI,
    U256,
};

/// Random Oracle for pure randomness generation
#[derive(Contract)]
struct RandomOracle<SDK> {
    sdk: SDK,
}

/// API for pure randomness functions
pub trait RandomOracleAPI {
    /// Generate number of rounds for a tournament (1 to 10)
    fn generate_rounds(&self, seed: U256) -> U256;
    
    /// Generate a random number within a range
    fn get_random_number(&self, seed: U256, range: U256) -> U256;
    
    /// Generate a random seed
    fn get_random_seed(&self) -> U256;
}

#[router(mode = "solidity")]
impl<SDK: SharedAPI> RandomOracleAPI for RandomOracle<SDK> {
    fn generate_rounds(&self, seed: U256) -> U256 {
        let block_number = self.sdk.block_number();
        let block_timestamp = self.sdk.block_timestamp();
        
        let mixed = block_number
            .wrapping_add(block_timestamp)
            .wrapping_mul(seed.wrapping_add(U256::from(1)));
        
        (mixed % U256::from(10)) + U256::from(1)
    }
    
    fn get_random_number(&self, seed: U256, range: U256) -> U256 {
        if range == U256::from(0) {
            return U256::from(0);
        }
        
        let block_number = self.sdk.block_number();
        let block_timestamp = self.sdk.block_timestamp();
        
        let mixed = block_number
            .wrapping_add(block_timestamp)
            .wrapping_add(seed);
        
        mixed % range
    }
    
    fn get_random_seed(&self) -> U256 {
        let block_number = self.sdk.block_number();
        let block_timestamp = self.sdk.block_timestamp();
        
        block_number.wrapping_mul(block_timestamp)
    }
}

basic_entrypoint!(RandomOracle);
