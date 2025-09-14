import { useAccount } from 'wagmi'
import { formatEther } from 'viem'
import { useGameContract, useGameStatus } from '../hooks/useGameContract'
import { MOVES, MOVE_NAMES, MOVE_EMOJIS, GAME_STATES } from '../utils/constants'
import type { Move } from '../types/game'

export function GameBoard() {
  const { address } = useAccount()
  const { playRound, isPlayRoundPending } = useGameContract()
  const { gameStatus } = useGameStatus(address)

  if (!gameStatus || gameStatus.state === GAME_STATES.NOT_STARTED) {
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="text-center text-gray-500">
          <p>No active game. Start a new game to play!</p>
        </div>
      </div>
    )
  }

  if (gameStatus.state === GAME_STATES.COMPLETED) {
    const playerWon = gameStatus.playerWins > gameStatus.computerWins
    const computerWon = gameStatus.computerWins > gameStatus.playerWins
    const isDraw = gameStatus.playerWins === gameStatus.computerWins

    return (
      <div className="bg-white border border-gray-200 rounded-lg p-6">
        <div className="text-center">
          <h3 className="text-xl font-bold mb-4">Game Complete!</h3>
          <div className={`text-2xl font-bold mb-4 ${
            playerWon ? 'text-green-600' : computerWon ? 'text-red-600' : 'text-yellow-600'
          }`}>
            {playerWon ? '🎉 You Won!' : computerWon ? '💻 Computer Won!' : '🤝 Draw!'}
          </div>
          <div className="space-y-2 text-gray-600">
            <p>Your Wins: {gameStatus.playerWins.toString()}</p>
            <p>Computer Wins: {gameStatus.computerWins.toString()}</p>
            <p>Total Pot: {formatEther(gameStatus.totalPot)} ETH</p>
          </div>
        </div>
      </div>
    )
  }

  // Game in progress
  const handleMoveClick = (move: Move) => {
    playRound(move)
  }

  const isGameComplete = gameStatus.currentRound >= gameStatus.totalRounds

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6">
      <div className="text-center mb-6">
        <h3 className="text-xl font-semibold text-gray-800 mb-2">Game in Progress</h3>
        <div className="flex justify-center space-x-8 text-sm text-gray-600">
          <div>Round {gameStatus.currentRound.toString()}/{gameStatus.totalRounds.toString()}</div>
          <div>Pot: {formatEther(gameStatus.totalPot)} ETH</div>
        </div>
      </div>

      {/* Score display */}
      <div className="flex justify-center space-x-8 mb-6">
        <div className="text-center">
          <p className="text-sm text-gray-600">You</p>
          <p className="text-2xl font-bold text-green-600">{gameStatus.playerWins.toString()}</p>
        </div>
        <div className="text-center">
          <p className="text-sm text-gray-600">Computer</p>
          <p className="text-2xl font-bold text-red-600">{gameStatus.computerWins.toString()}</p>
        </div>
      </div>

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
  )
}
