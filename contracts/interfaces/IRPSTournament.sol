// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRPSTournament
 * @notice Interface for Rock-Paper-Scissors tournament with betting functionality
 * @dev Defines the core game mechanics and state management for cross-VM gaming
 * @author rakshithvk19
 */
interface IRPSTournament {
    
    /**
     * @notice Possible moves in Rock-Paper-Scissors
     * @dev Used for both player and computer move selection
     */
    enum Move { 
        ROCK,       // 0 - Beats Scissors
        PAPER,      // 1 - Beats Rock  
        SCISSORS    // 2 - Beats Paper
    }
    
    /**
     * @notice Game state progression
     * @dev Tracks the lifecycle of a tournament game
     */
    enum GameState { 
        NOT_STARTED,    // 0 - No active game for player
        IN_PROGRESS,    // 1 - Game active, rounds being played
        COMPLETED       // 2 - Game finished, payouts distributed
    }

    /**
     * @notice Start a new tournament game with ETH bet
     * @dev Creates new game instance, gets computer bet, begins tournament
     * Requirements:
     * - msg.value > 0 (player must bet ETH)
     * - No game currently in progress for msg.sender
     * - Computer must have sufficient funds to match betting logic
     * Emits: GameStarted event
     */
    function startGame() external payable;
    
    /**
     * @notice Play a single round of Rock-Paper-Scissors
     * @dev Processes player move against computer AI move, updates score
     * @param playerMove The move chosen by the player (Rock/Paper/Scissors)
     * Requirements:
     * - Active game must exist for msg.sender
     * - Game must be in IN_PROGRESS state
     * - Current round must be less than total rounds
     * Emits: RoundPlayed event
     * Emits: GameCompleted event (if final round)
     */
    function playRound(Move playerMove) external;
    
    /**
     * @notice Get comprehensive status of player's current game
     * @dev Returns all relevant game state information
     * @param player Address of the player to check
     * @return state Current game state (NOT_STARTED/IN_PROGRESS/COMPLETED)
     * @return totalRounds Total number of rounds in this tournament
     * @return currentRound Number of rounds completed (0-indexed)
     * @return playerWins Number of rounds won by player
     * @return computerWins Number of rounds won by computer
     * @return playerBet Amount of ETH bet by player (in wei)
     * @return computerBet Amount of ETH bet by computer (in wei)
     * @return totalPot Combined pot of both bets (playerBet + computerBet)
     */
    function getGameStatus(address player) external view returns (
        GameState state,
        uint256 totalRounds,
        uint256 currentRound,
        uint256 playerWins,
        uint256 computerWins,
        uint256 playerBet,
        uint256 computerBet,
        uint256 totalPot
    );
    
    /**
     * @notice Get historical moves for a game (deprecated - use events)
     * @dev Returns empty arrays - clients should query RoundPlayed events instead
     * @param player Address of the player
     * @return playerMoves Empty array (use events for history)
     * @return computerMoves Empty array (use events for history)
     * @custom:deprecated Use RoundPlayed events for move history instead
     */
    function getMoveHistory(address player) external pure returns (
        uint256[] memory playerMoves, 
        uint256[] memory computerMoves
    );
}