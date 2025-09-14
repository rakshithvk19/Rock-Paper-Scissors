// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IFundManager
/// @notice Interface for managing computer's betting funds
interface IFundManager {
    /// @notice Place a bet for the computer
    /// @param amount Bet amount in wei
    /// @return success Whether bet was placed successfully
    function computer_bet(uint256 amount) external returns (bool success);
    
    /// @notice Get computer's current balance
    /// @return Current balance in wei
    function get_computer_balance() external view returns (uint256);
    
    /// @notice Get maximum bet limit
    /// @return Maximum allowed bet amount
    function get_max_bet_limit() external view returns (uint256);
    
    /// @notice Check if computer can afford a bet
    /// @param amount Bet amount to check
    /// @return Whether computer can afford the bet
    function can_afford_bet(uint256 amount) external view returns (bool);
}
