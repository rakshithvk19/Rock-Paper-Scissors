import {
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
  useWatchContractEvent,
} from "wagmi";
import { parseEther } from "viem";
import { useState, useEffect } from "react";
import { RPSTournamentABI } from "../contracts";
import { CONTRACT_ADDRESSES } from "../utils/constants";
import type { GameStatus, Move } from "../types/game";

/**
 * Round data structure for game history
 */
export interface RoundData {
  round: number;
  playerMove: number;
  computerMove: number;
  result: string;
}

/**
 * useTournament Hook
 * 
 * Main hook for interacting with the RPSTournament smart contract.
 * Manages game state, round history, and blockchain transactions.
 * 
 * Features:
 * - Game state management (status, rounds, scores)
 * - Round history tracking (current session only)
 * - Transaction handling (start game, play round)
 * - Error message management
 * - Real-time event listening for game updates
 * - Automatic data refresh on blockchain events
 * 
 * @param playerAddress - The connected wallet address
 * @returns Game state, actions, and transaction status
 */
export function useTournament(playerAddress: `0x${string}` | undefined) {
  // Local state for session-based round history and error messages
  const [roundHistory, setRoundHistory] = useState<RoundData[]>([]);
  const [startGameErrorMsg, setStartGameErrorMsg] = useState<string>("");
  const [playRoundErrorMsg, setPlayRoundErrorMsg] = useState<string>("");

  // Game status
  const { data: gameStatus, refetch: refetchStatus } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: "getGameStatus",
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
    },
  });

  // Start Game Action
  const {
    writeContract: startGameWrite,
    data: startGameHash,
    error: startGameError,
  } = useWriteContract();

  // Play Round Action
  const {
    writeContract: playRoundWrite,
    data: playRoundHash,
    error: playRoundError,
  } = useWriteContract();

  /**
   * Parses blockchain errors into user-friendly messages
   * @param error - The error object from a failed transaction
   * @returns Human-readable error message
   */
  const getErrorMessage = (error: any): string => {
    if (!error) return "";

    const message = error.message || error.toString();

    if (message.includes("GameAlreadyInProgress")) {
      return "Please finish your current game first";
    }
    if (message.includes("MustPlaceBet")) {
      return "You must place a bet to start the game";
    }
    if (message.includes("NoActiveGame")) {
      return "No active game found. Start a new game first";
    }
    if (message.includes("GameAlreadyCompleted")) {
      return "This game is already completed";
    }
    if (message.includes("ComputerBetFailed")) {
      return "Computer doesn't have enough funds to match your bet";
    }
    if (message.includes("user rejected") || message.includes("User denied")) {
      return "Transaction cancelled";
    }
    if (message.includes("insufficient funds")) {
      return "Insufficient funds in your wallet";
    }

    return "Transaction failed. Please try again";
  };

  // Handle errors
  useEffect(() => {
    if (startGameError) {
      setStartGameErrorMsg(getErrorMessage(startGameError));
    }
  }, [startGameError]);

  useEffect(() => {
    if (playRoundError) {
      setPlayRoundErrorMsg(getErrorMessage(playRoundError));
    }
  }, [playRoundError]);

  /**
   * Starts a new tournament game with the specified bet amount
   * @param betAmount - Amount to bet in ETH
   */
  const startGame = (betAmount: number) => {
    setStartGameErrorMsg(""); // Clear previous errors
    startGameWrite({
      address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
      abi: RPSTournamentABI,
      functionName: "startGame",
      value: parseEther(betAmount.toString()),
    });
  };

  /**
   * Plays a round with the selected move
   * @param move - Player's move (Rock/Paper/Scissors)
   */
  const playRound = (move: Move) => {
    setPlayRoundErrorMsg(""); // Clear previous errors
    playRoundWrite({
      address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
      abi: RPSTournamentABI,
      functionName: "playRound",
      args: [move],
    });
  };

  // Wait for transaction confirmations
  const { isLoading: isStartGamePending } = useWaitForTransactionReceipt({
    hash: startGameHash,
  });

  const { isLoading: isPlayRoundPending } = useWaitForTransactionReceipt({
    hash: playRoundHash,
  });

  // Clear error messages when transactions succeed
  useEffect(() => {
    if (startGameHash) {
      setStartGameErrorMsg("");
    }
  }, [startGameHash]);

  useEffect(() => {
    if (playRoundHash) {
      setPlayRoundErrorMsg("");
    }
  }, [playRoundHash]);

  // Event listener: GameStarted - Clear history and refresh status
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    eventName: "GameStarted",
    args: playerAddress ? { player: playerAddress } : undefined,
    onLogs() {
      setRoundHistory([]);
      refetchStatus();
    },
  });

  // Event listener: RoundPlayed - Update round history
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    eventName: "RoundPlayed",
    args: playerAddress ? { player: playerAddress } : undefined,
    onLogs(logs) {
      const newRounds = logs.map((log) => ({
        round: Number(log.args.round),
        playerMove: Number(log.args.playerMove),
        computerMove: Number(log.args.computerMove),
        result: log.args.result as string,
      }));

      setRoundHistory((prev) => {
        const combined = [...prev, ...newRounds];
        const unique = Array.from(
          new Map(combined.map((r) => [r.round, r])).values()
        );
        return unique.sort((a, b) => a.round - b.round);
      });

      refetchStatus();
    },
  });

  // Event listener: GameCompleted - Refresh game status
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    eventName: "GameCompleted",
    args: playerAddress ? { player: playerAddress } : undefined,
    onLogs() {
      refetchStatus();
    },
  });

  // Return empty state if no player address
  if (!playerAddress) {
    return {
      gameStatus: undefined,
      roundHistory: [],
      isLoadingHistory: false,
      startGame,
      playRound,
      isStartGamePending,
      isPlayRoundPending,
      startGameErrorMsg,
      playRoundErrorMsg,
      refetchStatus,
    };
  }

  // Return full game state and actions
  return {
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

    roundHistory,
    isLoadingHistory: false,

    startGame,
    playRound,
    isStartGamePending,
    isPlayRoundPending,

    // Error messages
    startGameErrorMsg,
    playRoundErrorMsg,

    refetchStatus,
  };
}
