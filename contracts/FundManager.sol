// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IFundManager.sol";

/// @title FundManager
/// @notice Manages computer's betting funds and limits
contract FundManager is IFundManager {
    address public owner;
    address public gameContract;
    uint256 public computerBalance;
    uint256 public maxBetLimit;
    
    event FundsDeposited(uint256 amount);
    event FundsWithdrawn(uint256 amount);
    event BetPlaced(uint256 amount);
    event MaxBetLimitUpdated(uint256 newLimit);
    event GameContractUpdated(address newContract);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyGame() {
        require(msg.sender == gameContract, "Only game contract");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        maxBetLimit = 0.01 ether; // Default max bet
    }
    
    /// @notice Deposit funds for computer betting
    function depositFunds() external payable onlyOwner {
        computerBalance += msg.value;
        emit FundsDeposited(msg.value);
    }
    
    /// @notice Withdraw funds from computer balance
    /// @param amount Amount to withdraw
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= computerBalance, "Insufficient balance");
        computerBalance -= amount;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(amount);
    }
    
    /// @notice Set the game contract address
    /// @param _gameContract Address of the game contract
    function setGameContract(address _gameContract) external onlyOwner {
        gameContract = _gameContract;
        emit GameContractUpdated(_gameContract);
    }
    
    /// @notice Set maximum bet limit
    /// @param _maxBetLimit New maximum bet limit
    function setMaxBetLimit(uint256 _maxBetLimit) external onlyOwner {
        maxBetLimit = _maxBetLimit;
        emit MaxBetLimitUpdated(_maxBetLimit);
    }
    
    /// @notice Place a bet for the computer
    /// @param amount Bet amount in wei
    /// @return success Whether bet was placed successfully
    function computer_bet(uint256 amount) external onlyGame returns (bool success) {
        if (amount > computerBalance || amount > maxBetLimit) {
            return false;
        }
        
        computerBalance -= amount;
        emit BetPlaced(amount);
        return true;
    }
    
    /// @notice Get computer's current balance
    /// @return Current balance in wei
    function get_computer_balance() external view returns (uint256) {
        return computerBalance;
    }
    
    /// @notice Get maximum bet limit
    /// @return Maximum allowed bet amount
    function get_max_bet_limit() external view returns (uint256) {
        return maxBetLimit;
    }
    
    /// @notice Check if computer can afford a bet
    /// @param amount Bet amount to check
    /// @return Whether computer can afford the bet
    function can_afford_bet(uint256 amount) external view returns (bool) {
        return amount <= computerBalance && amount <= maxBetLimit;
    }
    
    /// @notice Add winnings to computer balance
    /// @param amount Winning amount to add
    function addWinnings(uint256 amount) external onlyGame {
        computerBalance += amount;
    }
    
    /// @notice Emergency withdraw all funds
    function emergencyWithdraw() external onlyOwner {
        uint256 amount = computerBalance;
        computerBalance = 0;
        payable(owner).transfer(amount);
        emit FundsWithdrawn(amount);
    }
}
