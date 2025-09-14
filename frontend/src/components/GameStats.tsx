import { useAccount } from 'wagmi'
import { formatEther } from 'viem'
import { useWalletBalance } from '../hooks/useBalance'
import { useComputerBalance } from '../hooks/useGameContract'

export function GameStats() {
  const { address } = useAccount()
  const { formattedBalance } = useWalletBalance(address)
  const { computerBalance } = useComputerBalance()

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6">
      <h3 className="text-lg font-semibold text-gray-800 mb-4">Game Stats</h3>
      
      <div className="space-y-4">
        {/* Player balance */}
        <div className="flex justify-between items-center">
          <span className="text-gray-600">Your Balance:</span>
          <span className="font-semibold text-green-600">{formattedBalance} ETH</span>
        </div>

        {/* Computer balance */}
        <div className="flex justify-between items-center">
          <span className="text-gray-600">Computer Balance:</span>
          <span className="font-semibold text-blue-600">
            {computerBalance ? formatEther(computerBalance) : '0'} ETH
          </span>
        </div>

        {/* Network info */}
        <div className="pt-4 border-t border-gray-100">
          <div className="flex justify-between items-center text-sm">
            <span className="text-gray-500">Network:</span>
            <span className="text-gray-700">Fluent Testnet</span>
          </div>
        </div>
      </div>
    </div>
  )
}
