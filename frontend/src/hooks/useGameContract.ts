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
      gas: BigInt(500000), 
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

    console.log('useGameStatus params:', { playerAddress, tournamentAddress: CONTRACT_ADDRESSES.TOURNAMENT })

  const { data: gameStatus, refetch } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: 'getGameStatus',
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
      refetchInterval: 10000, // Poll every 10 seconds
    },
  })

    console.log('useGameStatus result:', gameStatus)


  // return {
  //   gameStatus: gameStatus as GameStatus | undefined,
  //   refetchGameStatus: refetch,
  // }

  return {
  gameStatus: gameStatus ? {
    state: gameStatus[0],
    totalRounds: gameStatus[1], 
    currentRound: gameStatus[2],
    playerWins: gameStatus[3],
    computerWins: gameStatus[4],
    playerBet: gameStatus[5],
    computerBet: gameStatus[6], 
    totalPot: gameStatus[7],
  } as GameStatus : undefined,
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
      refetchInterval: 15000, // Poll every 15 seconds
    },
  })

  return {
    computerBalance: balance as bigint | undefined,
  }
}
