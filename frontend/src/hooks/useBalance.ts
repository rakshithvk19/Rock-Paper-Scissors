import { useBalance, useReadContract } from "wagmi";
import { formatEther } from "viem";
import { FundManagerABI, RPSTournamentABI } from "../contracts";
import { CONTRACT_ADDRESSES } from "../utils/constants";

export function useBalances(playerAddress: `0x${string}` | undefined) {
  // User wallet balance
  const { data: walletBalance, refetch: refetchWallet } = useBalance({
    address: playerAddress,
    query: {
      enabled: !!playerAddress,
      refetchInterval: 15000,
    },
  });

  // Computer balance from FundManager
  const { data: computerBalance, refetch: refetchComputer } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: "get_computer_balance",
    query: {
      refetchInterval: 15000,
    },
  });

  // Current pot from Tournament (if active game exists)
  const { data: gameStatus, refetch: refetchPot } = useReadContract({
    address: CONTRACT_ADDRESSES.TOURNAMENT as `0x${string}`,
    abi: RPSTournamentABI,
    functionName: "getGameStatus",
    args: playerAddress ? [playerAddress] : undefined,
    query: {
      enabled: !!playerAddress,
      refetchInterval: 15000,
    },
  });

  const currentPot = gameStatus ? gameStatus[7] : 0n; // totalPot is index 7

  return {
    // Raw balances
    walletBalance: walletBalance?.value || 0n,
    computerBalance: (computerBalance as bigint) || 0n,
    currentPot,

    // Formatted balances
    formattedWallet: formatEther(walletBalance?.value || 0n),
    formattedComputer: formatEther((computerBalance as bigint) || 0n),
    formattedPot: formatEther(currentPot),

    // Utilities
    canAfford: (amount: number) => {
      const balanceInEth = parseFloat(formatEther(walletBalance?.value || 0n));
      return balanceInEth >= amount;
    },

    // Refetch functions
    refetchAll: () => {
      refetchWallet();
      refetchComputer();
      refetchPot();
    },
  };
}
