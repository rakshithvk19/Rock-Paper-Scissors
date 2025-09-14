import { useState } from 'react'
import { useAccount } from 'wagmi'
import { useGameContract } from '../hooks/useGameContract'
import { useWalletBalance } from '../hooks/useBalance'
import { MIN_BET_ETH, MAX_BET_ETH, BET_STEP_ETH, QUICK_BET_OPTIONS } from '../utils/constants'

export function BettingPanel() {
  const { address } = useAccount()
  const { startGame, isStartGamePending } = useGameContract()
  const { formattedBalance } = useWalletBalance(address)
  const [betAmount, setBetAmount] = useState(MIN_BET_ETH)

  const handleStartGame = () => {
    if (betAmount > 0) {
      startGame(betAmount)
    }
  }

  const canAffordBet = parseFloat(formattedBalance) >= betAmount

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6">
      <h3 className="text-lg font-semibold text-gray-800 mb-4">Place Your Bet</h3>
      
      {/* Balance display */}
      <div className="mb-4">
        <p className="text-sm text-gray-600">Your Balance: {formattedBalance} ETH</p>
      </div>

      {/* Bet amount slider */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Bet Amount: {betAmount} ETH
        </label>
        <input
          type="range"
          min={MIN_BET_ETH}
          max={MAX_BET_ETH}
          step={BET_STEP_ETH}
          value={betAmount}
          onChange={(e) => setBetAmount(parseFloat(e.target.value))}
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
        />
        <div className="flex justify-between text-xs text-gray-500 mt-1">
          <span>{MIN_BET_ETH} ETH</span>
          <span>{MAX_BET_ETH} ETH</span>
        </div>
      </div>

      {/* Quick select buttons */}
      <div className="mb-6">
        <p className="text-sm font-medium text-gray-700 mb-2">Quick Select:</p>
        <div className="grid grid-cols-2 gap-2">
          {QUICK_BET_OPTIONS.map((option) => (
            <button
              key={option.value}
              onClick={() => setBetAmount(option.value)}
              className={`py-2 px-3 rounded-lg border text-sm transition-colors ${
                betAmount === option.value
                  ? 'bg-blue-500 text-white border-blue-500'
                  : 'bg-gray-50 text-gray-700 border-gray-200 hover:bg-gray-100'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      {/* Start game button */}
      <button
        onClick={handleStartGame}
        disabled={!canAffordBet || isStartGamePending || !address}
        className={`w-full py-3 px-4 rounded-lg font-semibold transition-colors ${
          canAffordBet && !isStartGamePending && address
            ? 'bg-green-500 text-white hover:bg-green-600'
            : 'bg-gray-300 text-gray-500 cursor-not-allowed'
        }`}
      >
        {isStartGamePending ? 'Starting Game...' : `Start Game (${betAmount} ETH)`}
      </button>

      {!canAffordBet && address && (
        <p className="text-red-500 text-sm mt-2">Insufficient balance</p>
      )}
    </div>
  )
}
