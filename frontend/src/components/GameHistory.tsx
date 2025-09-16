import { useAccount } from 'wagmi'
import { useGameHistory } from '../hooks/useGameContract'
import { MOVE_NAMES, MOVE_EMOJIS } from '../utils/constants'

export function GameHistory() {
  const { address } = useAccount()
  const { moveHistory } = useGameHistory(address)

  // Better safety checks
  if (!moveHistory || !moveHistory.playerMoves || !moveHistory.computerMoves || moveHistory.playerMoves.length === 0) {
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Game History</h3>
        <p className="text-gray-500 text-center">No moves played yet</p>
      </div>
    )
  }

  const rounds = moveHistory.playerMoves.map((playerMove, index) => {
    const computerMove = moveHistory.computerMoves[index]
    const playerMoveIndex = Number(playerMove)
    const computerMoveIndex = Number(computerMove)
    
    // Determine winner
    let result = 'Draw'
    if (playerMove !== computerMove) {
      const playerWins = 
        (playerMoveIndex === 0 && computerMoveIndex === 2) || // Rock vs Scissors
        (playerMoveIndex === 1 && computerMoveIndex === 0) || // Paper vs Rock
        (playerMoveIndex === 2 && computerMoveIndex === 1)    // Scissors vs Paper
      result = playerWins ? 'You won' : 'Computer won'
    }

    return {
      round: index + 1,
      playerMove: playerMoveIndex,
      computerMove: computerMoveIndex,
      result,
    }
  })

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6">
      <h3 className="text-lg font-semibold text-gray-800 mb-4">Game History</h3>
      
      <div className="space-y-3 max-h-60 overflow-y-auto">
        {rounds.map((round) => (
          <div key={round.round} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center space-x-4">
              <span className="text-sm font-medium text-gray-600">Round {round.round}</span>
              <div className="flex items-center space-x-2">
                <span className="text-xl">{MOVE_EMOJIS[round.playerMove]}</span>
                <span className="text-sm text-gray-500">vs</span>
                <span className="text-xl">{MOVE_EMOJIS[round.computerMove]}</span>
              </div>
              <div className="text-sm text-gray-600">
                {MOVE_NAMES[round.playerMove]} vs {MOVE_NAMES[round.computerMove]}
              </div>
            </div>
            <span className={`text-sm font-medium ${
              round.result === 'You won' ? 'text-green-600' :
              round.result === 'Computer won' ? 'text-red-600' :
              'text-yellow-600'
            }`}>
              {round.result}
            </span>
          </div>
        ))}
      </div>
    </div>
  )
}
