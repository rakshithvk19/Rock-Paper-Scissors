// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IFundManager
 * @notice Interface for managing computer AI's betting funds and game interactions
 * @dev Handles computer's bankroll, betting limits, and win/loss accounting
 */
interface IFundManager {
    /**
     * @notice Place a bet on behalf of the computer AI
     * @dev Transfers specified amount to game contract for betting
     * @param amount Amount to bet in wei
     * @return success Whether the bet was successfully placed
     * Requirements:
     * - Only callable by authorized game contract
     * - Amount must not exceed contract balance
     * - Amount must not exceed maximum bet limit
     */
    function computer_bet(uint256 amount) external returns (bool success);

    /**
     * @notice Get computer's current available balance
     * @dev Returns the actual ETH balance of this contract
     * @return Current balance in wei
     */
    function get_computer_balance() external view returns (uint256);

    /**
     * @notice Get the maximum allowed bet amount
     * @dev Used by game contract to validate betting limits
     * @return Maximum bet limit in wei
     */
    function get_max_bet_limit() external view returns (uint256);

    /**
     * @notice Check if computer can afford a specific bet amount
     * @dev Validates against both balance and bet limits
     * @param amount Amount to validate in wei
     * @return Whether the computer can afford this bet
     */
    function can_afford_bet(uint256 amount) external view returns (bool);

    /**
     * @notice Add winnings to computer's balance
     * @dev Called by game contract when computer wins
     * @param amount Amount of winnings (must match msg.value)
     * Requirements:
     * - Only callable by authorized game contract
     * - msg.value must equal amount parameter
     */
    function addWinnings(uint256 amount) external payable;

    /**
     * @notice Deposit additional funds for computer betting
     * @dev Allows owner to add more ETH to computer's bankroll
     * Requirements:
     * - Only callable by contract owner
     * - Must send ETH with transaction
     */
    function depositFunds() external payable;

    /**
     * @notice Withdraw specified amount from computer's balance
     * @dev Allows owner to extract profits or adjust bankroll
     * @param amount Amount to withdraw in wei
     * Requirements:
     * - Only callable by contract owner
     * - Amount must not exceed available balance
     */
    function withdrawFunds(uint256 amount) external;

    /**
     * @notice Set the authorized game contract address
     * @dev Updates which contract can place bets and add winnings
     * @param _gameContract Address of the tournament contract
     * Requirements:
     * - Only callable by contract owner
     * - Can optionally include ETH to fund the computer
     */
    function setGameContract(address _gameContract) external payable;

    /**
     * @notice Update the maximum bet limit
     * @dev Allows owner to adjust risk management parameters
     * @param _maxBetLimit New maximum bet amount in wei
     * Requirements:
     * - Only callable by contract owner
     */
    function setMaxBetLimit(uint256 _maxBetLimit) external;

    /**
     * @notice Emergency function to withdraw all funds
     * @dev Last resort function for contract migration or emergencies
     * Requirements:
     * - Only callable by contract owner
     */
    function emergencyWithdraw() external;
}
