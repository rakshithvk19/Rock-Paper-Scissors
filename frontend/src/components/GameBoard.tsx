import { useAccount } from "wagmi";
import { formatEther } from "viem";
import { useTournament } from "../hooks/useTournament";
import {
  MOVES,
  MOVE_NAMES,
  MOVE_EMOJIS,
  GAME_STATES,
} from "../utils/constants";
import type { Move } from "../types/game";

/**
 * GameBoard Component
 * 
 * Main game interface for playing Rock-Paper-Scissors rounds.
 * Displays the current game state, score, and move selection buttons.
 * 
 * Features:
 * - Shows game progress (current round, total rounds, pot amount)
 * - Displays running score for player vs computer
 * - Move selection interface with emoji buttons
 * - Error message display for failed transactions
 * - Different states for not started, in progress, and completed games
 * 
 * @component
 */
export function GameBoard() {
  const { address } = useAccount();
  const { playRound, isPlayRoundPending, gameStatus, playRoundErrorMsg } =
    useTournament(address);

  // Display placeholder when no game is active
  if (!gameStatus || gameStatus.state === GAME_STATES.NOT_STARTED) {
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="text-center text-gray-500">
          <p>No active game. Start a new game to play!</p>
        </div>
      </div>
    );
  }

  // Display game results when completed
  if (gameStatus.state === GAME_STATES.COMPLETED) {
    const playerWon =
      (gameStatus.playerWins || 0n) > (gameStatus.computerWins || 0n);
    const computerWon =
      (gameStatus.computerWins || 0n) > (gameStatus.playerWins || 0n);

    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="text-center">
          <h3 className="text-xl font-bold mb-4">Game Complete!</h3>
          <div
            className={`text-2xl font-bold mb-4 ${
              playerWon
                ? "text-green-600"
                : computerWon
                ? "text-red-600"
                : "text-yellow-600"
            }`}
          >
            {playerWon
              ? "🎉 You Won!"
              : computerWon
              ? "💻 Computer Won!"
              : "🤝 Draw!"}
          </div>
          <div className="space-y-2 text-gray-600">
            <p>Your Wins: {gameStatus.playerWins?.toString() || "0"}</p>
            <p>Computer Wins: {gameStatus.computerWins?.toString() || "0"}</p>
            <p>Total Pot: {formatEther(gameStatus.totalPot || 0n)} ETH</p>
          </div>
        </div>
      </div>
    );
  }

  // Game in progress - Main gameplay interface
  
  /**
   * Handles player's move selection
   * @param move - The move selected by the player (Rock/Paper/Scissors)
   */
  const handleMoveClick = (move: Move) => {
    playRound(move);
  };

  // Check if all rounds have been played
  const isGameComplete =
    (gameStatus.currentRound || 0n) >= (gameStatus.totalRounds || 0n);

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6">
      <div className="text-center mb-6">
        <h3 className="text-xl font-semibold text-gray-800 mb-2">
          Game in Progress
        </h3>
        <div className="flex justify-center space-x-8 text-sm text-gray-600">
          <div>
            Round {((gameStatus.currentRound || 0n) + 1n).toString()}/
            {gameStatus.totalRounds?.toString() || "0"}
          </div>
          <div>Pot: {formatEther(gameStatus.totalPot || 0n)} ETH</div>
        </div>
      </div>

      {/* Score display */}
      <div className="flex justify-center space-x-8 mb-6">
        <div className="text-center">
          <p className="text-sm text-gray-600">You</p>
          <p className="text-2xl font-bold text-green-600">
            {gameStatus.playerWins?.toString() || "0"}
          </p>
        </div>
        <div className="text-center">
          <p className="text-sm text-gray-600">Computer</p>
          <p className="text-2xl font-bold text-red-600">
            {gameStatus.computerWins?.toString() || "0"}
          </p>
        </div>
      </div>

      {/* Error message display */}
      {playRoundErrorMsg && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-red-600 text-sm flex items-center justify-center">
            <span className="mr-2">⚠️</span>
            {playRoundErrorMsg}
          </p>
        </div>
      )}

      {/* Move selection */}
      {!isGameComplete && (
        <div>
          <p className="text-center text-gray-700 mb-4">Choose your move:</p>
          <div className="flex justify-center space-x-4">
            {Object.values(MOVES).map((move) => (
              <button
                key={move}
                onClick={() => handleMoveClick(move)}
                disabled={isPlayRoundPending}
                className="flex flex-col items-center p-4 border-2 border-gray-200 rounded-lg hover:border-blue-300 hover:bg-blue-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span className="text-4xl mb-2">{MOVE_EMOJIS[move]}</span>
                <span className="text-sm font-medium">{MOVE_NAMES[move]}</span>
              </button>
            ))}
          </div>
          {isPlayRoundPending && (
            <p className="text-center text-blue-600 mt-4">Playing round...</p>
          )}
        </div>
      )}
    </div>
  );
}
