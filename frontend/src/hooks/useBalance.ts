import { useBalance, useWatchContractEvent } from "wagmi";
import { formatEther } from "viem";
import { useFundManager } from "./useFundManager";
import { useTournament } from "./useTournament";
import { RPSTournamentABI } from "../contracts";
import { CONTRACT_ADDRESSES } from "../utils/constants";

/**
 * useBalances Hook
 * 
 * Aggregates balance information from multiple sources.
 * Provides real-time balance updates for player, computer, and game pot.
 * 
 * Features:
 * - Player wallet balance tracking
 * - Computer fund balance monitoring
 * - Current game pot calculation
 * - Formatted balance strings for display
 * - Auto-refresh on game events (payouts, bets)
 * - Utility function to check affordability
 * 
 * @param playerAddress - The connected wallet address
 * @returns Balance information and utility functions
 */
export function useBalances(playerAddress: `0x${string}` | undefined) {
  const { computerBalance } = useFundManager();
  const { gameStatus } = useTournament(playerAddress);

  // User wallet balance
  const { data: walletBalance, refetch: refetchWallet } = useBalance({
    address: playerAddress,
    query: {
      enabled: !!playerAddress,
    },
  });

  // Event listener: GameCompleted - Refresh wallet balance for payouts
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    eventName: "GameCompleted",
    args: playerAddress ? { player: playerAddress } : undefined,
    onLogs() {
      // Refresh wallet balance when game completes (player might receive payout)
      refetchWallet();
    },
  });

  // Event listener: GameStarted - Refresh wallet after bet placement
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    eventName: "GameStarted",
    args: playerAddress ? { player: playerAddress } : undefined,
    onLogs() {
      // Refresh wallet balance when game starts (player placed bet)
      refetchWallet();
    },
  });

  const currentPot = gameStatus ? gameStatus.totalPot : 0n;

  return {
    // Raw balances
    walletBalance: walletBalance?.value || 0n,
    computerBalance: computerBalance || 0n,
    currentPot,

    // Formatted balances
    formattedWallet: formatEther(walletBalance?.value || 0n),
    formattedComputer: formatEther(computerBalance || 0n),
    formattedPot: formatEther(currentPot),

    // Utilities
    canAfford: (amount: number) => {
      const balanceInEth = parseFloat(formatEther(walletBalance?.value || 0n));
      return balanceInEth >= amount;
    },

    // Refetch functions
    refetchWallet,
  };
}
