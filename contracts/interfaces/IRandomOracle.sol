// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IRandomOracle
/// @notice Interface for the Rust-based Random Oracle contract
/// @dev This interface enables cross-VM communication between Solidity and Rust on Fluent
interface IRandomOracle {
    /// @notice Generate the number of rounds for a tournament (3, 5, or 7)
    /// @param seed Random seed for generation
    /// @return Number of rounds to play
    function generate_rounds(uint256 seed) external view returns (uint256);
    
    /// @notice Get computer's move for a specific round
    /// @param round Current round number
    /// @param seed Game seed for randomness
    /// @return Move choice (0=Rock, 1=Paper, 2=Scissors)
    function get_rps_choice(uint256 round, uint256 seed) external view returns (uint256);
    
    /// @notice Determine the winner of a single round
    /// @param player_move Player's move
    /// @param computer_move Computer's move
    /// @return 0=draw, 1=player wins, 2=computer wins
    function check_round_winner(uint256 player_move, uint256 computer_move) external view returns (uint256);
    
    /// @notice Determine the tournament champion based on wins
    /// @param player_wins Number of rounds won by player
    /// @param computer_wins Number of rounds won by computer
    /// @param total_rounds Total rounds in tournament
    /// @return 0=ongoing, 1=player champion, 2=computer champion
    function determine_champion(uint256 player_wins, uint256 computer_wins, uint256 total_rounds) external view returns (uint256);
    
    /// @notice Calculate the majority threshold for winning
    /// @param total_rounds Total rounds in tournament
    /// @return Number of wins needed for majority
    function get_majority_threshold(uint256 total_rounds) external view returns (uint256);
}