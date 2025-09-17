import { useAccount } from "wagmi";
import { useTournament } from "../hooks/useTournament";
import { MOVE_NAMES, MOVE_EMOJIS } from "../utils/constants";

/**
 * GameHistory Component
 * 
 * Displays the history of rounds played in the current game session.
 * Shows each round's moves and results in a scrollable list.
 * 
 * Features:
 * - Displays round number, player move, computer move, and result
 * - Color-coded results (green for player wins, red for computer wins, yellow for draws)
 * - Shows move emojis and names for better visualization
 * - Scrollable container for games with many rounds
 * - Loading state while fetching history
 * 
 * Note: History is session-based and clears when a new game starts.
 * 
 * @component
 */
export function GameHistory() {
  const { address } = useAccount();
  const { roundHistory, isLoadingHistory } = useTournament(address);

  // Show loading state while fetching history
  if (isLoadingHistory) {
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">
          Game History
        </h3>
        <p className="text-gray-500 text-center">Loading history...</p>
      </div>
    );
  }

  // Show empty state when no rounds have been played
  if (!roundHistory || roundHistory.length === 0) {
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">
          Game History
        </h3>
        <p className="text-gray-500 text-center">No moves played yet</p>
      </div>
    );
  }

  // Render the history of played rounds
  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6">
      <h3 className="text-lg font-semibold text-gray-800 mb-4">Game History</h3>

      {/* Scrollable container for round history */}
      <div className="space-y-3 max-h-60 overflow-y-auto">
        {roundHistory.map((round) => (
          <div
            key={round.round}
            className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
          >
            <div className="flex items-center space-x-4">
              <span className="text-sm font-medium text-gray-600">
                Round {round.round}
              </span>
              <div className="flex items-center space-x-2">
                <span className="text-xl">{MOVE_EMOJIS[round.playerMove]}</span>
                <span className="text-sm text-gray-500">vs</span>
                <span className="text-xl">
                  {MOVE_EMOJIS[round.computerMove]}
                </span>
              </div>
              <div className="text-sm text-gray-600">
                {MOVE_NAMES[round.playerMove]} vs{" "}
                {MOVE_NAMES[round.computerMove]}
              </div>
            </div>
            {/* Color-coded result display */}
            <span
              className={`text-sm font-medium ${
                round.result === "Player wins"
                  ? "text-green-600"
                  : round.result === "Computer wins"
                  ? "text-red-600"
                  : "text-yellow-600"
              }`}
            >
              {round.result}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
