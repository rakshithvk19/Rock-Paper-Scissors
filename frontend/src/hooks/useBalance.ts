import { useBalance } from 'wagmi'
import { formatEther } from 'viem'

export function useWalletBalance(address: `0x${string}` | undefined) {
  const { data: balance, refetch } = useBalance({
    address,
    query: {
      enabled: !!address,
      refetchInterval: 15000, // Poll every 15 seconds
    },
  })

  const formattedBalance = balance ? formatEther(balance.value) : '0'

  return {
    balance: balance?.value,
    formattedBalance,
    refetchBalance: refetch,
  }
}
