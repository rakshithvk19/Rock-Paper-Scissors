// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IComputerAI
/// @notice Interface for computer AI decision making
interface IComputerAI {
    /// @notice Get computer's move for current round
    /// @param round Current round number
    /// @param seed Game seed for randomness
    /// @param playerHistory Array of player's previous moves
    /// @return Move choice (0=Rock, 1=Paper, 2=Scissors)
    function get_move(uint256 round, uint256 seed, uint256[] calldata playerHistory) external view returns (uint256);
    
    /// @notice Get computer's betting recommendation
    /// @param playerWins Player's current wins
    /// @param computerWins Computer's current wins
    /// @param totalRounds Total rounds in game
    /// @param currentRound Current round number
    /// @return Suggested bet amount in wei
    function get_betting_advice(uint256 playerWins, uint256 computerWins, uint256 totalRounds, uint256 currentRound) external view returns (uint256);
    
    /// @notice Get AI difficulty level
    /// @return Difficulty level (0=Easy, 1=Medium, 2=Hard)
    function get_difficulty() external view returns (uint256);
}
