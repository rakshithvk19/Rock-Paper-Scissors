// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IFundManager.sol";

/**
 * @title FundManager
 * @notice Manages computer AI's betting funds with security controls and limits
 * @dev Serves as the computer's "bank account" for tournament betting
 * @author rakshithvk19
 * @custom:security-contact security@fluent.xyz
 */
contract FundManager is IFundManager {
    // ============ CUSTOM ERRORS ============

    /// @notice Thrown when non-owner attempts owner-only function
    error OnlyOwner();

    /// @notice Thrown when non-game contract attempts game-only function
    error OnlyGameContract();

    /// @notice Thrown when trying to withdraw more than available balance
    error InsufficientBalance();

    /// @notice Thrown when bet amount exceeds maximum limit
    error BetExceedsLimit();

    /// @notice Thrown when ETH transfer fails
    error TransferFailed();

    /// @notice Thrown when addWinnings ETH amount doesn't match parameter
    error EthAmountMismatch();

    /// @notice Thrown when setting invalid max bet limit (0)
    error InvalidBetLimit();

    /// @notice Thrown when setting invalid game contract (zero address)
    error InvalidGameContract();

    // ============ STATE VARIABLES ============

    /// @notice Contract owner (deployer) - has administrative control
    address public immutable owner;

    /// @notice Authorized game contract address - can place bets and add winnings
    address public gameContract;

    /// @notice Maximum bet amount per game (risk management)
    uint256 public maxBetLimit;

    // ============ EVENTS ============

    /**
     * @notice Emitted when funds are deposited to computer's balance
     * @param amount Amount deposited in wei
     * @param newBalance New total balance after deposit
     */
    event FundsDeposited(uint256 amount, uint256 newBalance);

    /**
     * @notice Emitted when funds are withdrawn from computer's balance
     * @param amount Amount withdrawn in wei
     * @param newBalance New total balance after withdrawal
     */
    event FundsWithdrawn(uint256 amount, uint256 newBalance);

    /**
     * @notice Emitted when computer places a bet
     * @param amount Amount bet in wei
     * @param remainingBalance Remaining balance after bet
     */
    event BetPlaced(uint256 amount, uint256 remainingBalance);

    /**
     * @notice Emitted when computer receives winnings
     * @param amount Winnings amount in wei
     * @param newBalance New total balance including winnings
     */
    event WinningsAdded(uint256 amount, uint256 newBalance);

    /**
     * @notice Emitted when maximum bet limit is updated
     * @param oldLimit Previous bet limit
     * @param newLimit New bet limit
     */
    event MaxBetLimitUpdated(uint256 oldLimit, uint256 newLimit);

    /**
     * @notice Emitted when game contract address is updated
     * @param oldContract Previous game contract (zero if first time)
     * @param newContract New authorized game contract
     */
    event GameContractUpdated(address oldContract, address newContract);

    // ============ MODIFIERS ============

    /**
     * @notice Restricts function access to contract owner only
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    /**
     * @notice Restricts function access to authorized game contract only
     */
    modifier onlyGameContract() {
        if (msg.sender != gameContract) revert OnlyGameContract();
        _;
    }

    /**
     * @notice Validates that contract has sufficient balance for operation
     * @param amount Amount to validate against balance
     */
    modifier hasSufficientBalance(uint256 amount) {
        if (amount > address(this).balance) revert InsufficientBalance();
        _;
    }

    // ============ CONSTRUCTOR ============

    /**
     * @notice Deploy FundManager with initial configuration
     * @dev Sets deployer as owner, initializes with sent ETH, sets default bet limit
     * @custom:param msg.value Initial funding for computer (recommended: 0.02 ETH)
     */
    constructor() payable {
        owner = msg.sender;
        maxBetLimit = 0.01 ether; // Conservative default limit

        if (msg.value > 0) {
            emit FundsDeposited(msg.value, msg.value);
        }
    }

    // ============ EXTERNAL FUNCTIONS ============

    /**
     * @inheritdoc IFundManager
     */
    function computer_bet(
        uint256 amount
    ) external override onlyGameContract returns (bool success) {
        // Validate bet amount
        if (amount > maxBetLimit) {
            return false; // Exceeds betting limit
        }
        if (amount > address(this).balance) {
            return false; // Insufficient funds
        }

        // Transfer bet amount to game contract
        (bool transferSuccess, ) = payable(msg.sender).call{value: amount}("");
        if (!transferSuccess) {
            return false; // Transfer failed
        }

        emit BetPlaced(amount, address(this).balance);
        return true;
    }

    /**
     * @inheritdoc IFundManager
     */
    function get_computer_balance() external view override returns (uint256) {
        return address(this).balance;
    }

    /**
     * @inheritdoc IFundManager
     */
    function get_max_bet_limit() external view override returns (uint256) {
        return maxBetLimit;
    }

    /**
     * @inheritdoc IFundManager
     */
    function can_afford_bet(
        uint256 amount
    ) external view override returns (bool) {
        return amount <= address(this).balance && amount <= maxBetLimit;
    }

    /**
     * @inheritdoc IFundManager
     */
    function addWinnings(
        uint256 amount
    ) external payable override onlyGameContract {
        if (msg.value != amount) revert EthAmountMismatch();

        emit WinningsAdded(amount, address(this).balance);
    }

    /**
     * @inheritdoc IFundManager
     */
    function depositFunds() external payable override onlyOwner {
        if (msg.value == 0) revert InsufficientBalance();

        emit FundsDeposited(msg.value, address(this).balance);
    }

    /**
     * @inheritdoc IFundManager
     */
    function withdrawFunds(
        uint256 amount
    ) external override onlyOwner hasSufficientBalance(amount) {
        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) revert TransferFailed();

        emit FundsWithdrawn(amount, address(this).balance);
    }

    /**
     * @inheritdoc IFundManager
     */
    function setGameContract(
        address _gameContract
    ) external payable override onlyOwner {
        if (_gameContract == address(0)) revert InvalidGameContract();

        address oldContract = gameContract;
        gameContract = _gameContract;

        // Handle optional funding
        if (msg.value > 0) {
            emit FundsDeposited(msg.value, address(this).balance);
        }

        emit GameContractUpdated(oldContract, _gameContract);
    }

    /**
     * @inheritdoc IFundManager
     */
    function setMaxBetLimit(uint256 _maxBetLimit) external override onlyOwner {
        if (_maxBetLimit == 0) revert InvalidBetLimit();

        uint256 oldLimit = maxBetLimit;
        maxBetLimit = _maxBetLimit;

        emit MaxBetLimitUpdated(oldLimit, _maxBetLimit);
    }

    /**
     * @inheritdoc IFundManager
     */
    function emergencyWithdraw() external override onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) revert InsufficientBalance();

        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) revert TransferFailed();

        emit FundsWithdrawn(amount, 0);
    }

    // ============ RECEIVE FUNCTION ============

    /**
     * @notice Allow contract to receive ETH from external sources
     * @dev ETH sent directly increases computer's available balance
     */
    receive() external payable {
        emit FundsDeposited(msg.value, address(this).balance);
    }
}
