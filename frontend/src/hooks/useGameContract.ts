import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { RPSTournamentABI, FundManagerABI } from '../contracts'
import { CONTRACT_ADDRESSES } from '../utils/constants'
import type { GameStatus, MoveHistory, Move } from '../types/game'

export function useGameContract() {
  const { writeContract: startGameWrite, data: startGameHash } = useWriteContract()
  const { writeContract: playRoundWrite, data: playRoundHash } = useWriteContract()

  const startGame = (betAmount: number) => {
    startGameWrite({
      address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
      abi: RPSTournamentABI,
      functionName: 'startGame',
      value: parseEther(betAmount.toString()),
    })
  }

  const playRound = (move: Move) => {
    playRoundWrite({
      address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
      abi: RPSTournamentABI,
      functionName: 'playRound',
      args: [move],
    })
  }

  const { isLoading: isStartGamePending } = useWaitForTransactionReceipt({
    hash: startGameHash,
  })

  const { isLoading: isPlayRoundPending } = useWaitForTransactionReceipt({
    hash: playRoundHash,
  })

  return {
    startGame,
    playRound,
    isStartGamePending,
    isPlayRoundPending,
  }
}

export function useGameStatus(playerAddress: `0x${string}` | undefined) {
  const { data: gameStatus, refetch } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: 'getGameStatus',
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
      refetchInterval: 2000, // Poll every 2 seconds
    },
  })

  return {
    gameStatus: gameStatus as GameStatus | undefined,
    refetchGameStatus: refetch,
  }
}

export function useGameHistory(playerAddress: `0x${string}` | undefined) {
  const { data: moveHistory } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: 'getMoveHistory',
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
    },
  })

  return {
    moveHistory: moveHistory as MoveHistory | undefined,
  }
}

export function useComputerBalance() {
  const { data: balance } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: 'get_computer_balance',
    query: {
      refetchInterval: 5000, // Poll every 5 seconds
    },
  })

  return {
    computerBalance: balance as bigint | undefined,
  }
}
