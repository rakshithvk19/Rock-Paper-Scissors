import {
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
} from "wagmi";
import { parseEther } from "viem";
import { RPSTournamentABI } from "../contracts";
import { CONTRACT_ADDRESSES } from "../utils/constants";
import type { GameStatus, MoveHistory, Move } from "../types/game";

export function useTournament(playerAddress: `0x${string}` | undefined) {
  // Game status
  const { data: gameStatus, refetch: refetchStatus } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: "getGameStatus",
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
      refetchInterval: 10000,
    },
  });

  // Move history
  const { data: moveHistory, refetch: refetchHistory } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: "getMoveHistory",
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
    },
  });

  // Actions
  const { writeContract: startGameWrite, data: startGameHash } =
    useWriteContract();
  const { writeContract: playRoundWrite, data: playRoundHash } =
    useWriteContract();

  const startGame = (betAmount: number) => {
    startGameWrite({
      address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
      abi: RPSTournamentABI,
      functionName: "startGame",
      value: parseEther(betAmount.toString()),
    });
  };

  const playRound = (move: Move) => {
    playRoundWrite({
      address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
      abi: RPSTournamentABI,
      functionName: "playRound",
      args: [move],
    });
  };

  const { isLoading: isStartGamePending } = useWaitForTransactionReceipt({
    hash: startGameHash,
  });

  const { isLoading: isPlayRoundPending } = useWaitForTransactionReceipt({
    hash: playRoundHash,
  });

  if (!playerAddress) {
    return {
      gameStatus: undefined,
      moveHistory: undefined,
      startGame,
      playRound,
      isStartGamePending,
      isPlayRoundPending,
    };
  }

  return {
    // Data
    gameStatus: gameStatus
      ? ({
          state: gameStatus[0],
          totalRounds: gameStatus[1],
          currentRound: gameStatus[2],
          playerWins: gameStatus[3],
          computerWins: gameStatus[4],
          playerBet: gameStatus[5],
          computerBet: gameStatus[6],
          totalPot: gameStatus[7],
        } as GameStatus)
      : undefined,

    moveHistory: moveHistory
      ? ({
          playerMoves: moveHistory[0] as bigint[],
          computerMoves: moveHistory[1] as bigint[],
        } as MoveHistory)
      : undefined,

    // Actions
    startGame,
    playRound,
    isStartGamePending,
    isPlayRoundPending,

    // Utilities
    refetchStatus,
    refetchHistory,
  };
}
