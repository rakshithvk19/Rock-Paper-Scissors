// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IRandomOracle
/// @notice Interface for pure randomness generation
interface IRandomOracle {
    /// @notice Generate the number of rounds for a tournament (1 to 10)
    /// @param seed Random seed for generation
    /// @return Number of rounds to play (1-10)
    function generate_rounds(uint256 seed) external view returns (uint256);
    
    /// @notice Generate a random number within a range
    /// @param seed Random seed for generation
    /// @param range Maximum value (exclusive)
    /// @return Random number between 0 and range-1
    function get_random_number(uint256 seed, uint256 range) external view returns (uint256);
    
    /// @notice Generate a random seed
    /// @return Random seed value
    function get_random_seed() external view returns (uint256);
}
