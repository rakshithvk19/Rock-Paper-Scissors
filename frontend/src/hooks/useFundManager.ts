import { useReadContract, useWatchContractEvent } from "wagmi";
import { FundManagerABI } from "../contracts";
import { CONTRACT_ADDRESSES } from "../utils/constants";
import { useState } from "react";

/**
 * useFundManager Hook
 * 
 * Manages interactions with the FundManager smart contract.
 * Tracks computer balance, betting limits, and fund events.
 * 
 * Features:
 * - Real-time computer balance tracking
 * - Max bet limit monitoring
 * - Event listeners for fund changes
 * - Owner and game contract information
 * - Tracks last bet and winnings amounts
 * 
 * @returns Fund manager state and configuration
 */
export function useFundManager() {
  // Track last bet and winnings for UI feedback
  const [lastBetAmount, setLastBetAmount] = useState<bigint | null>(null);
  const [lastWinningsAmount, setLastWinningsAmount] = useState<bigint | null>(
    null
  );

  const { data: maxBetLimit, refetch: refetchMaxBetLimit } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: "get_max_bet_limit",
  });

  const { data: owner } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: "owner",
  });

  const { data: computerBalance, refetch: refetchComputerBalance } =
    useReadContract({
      address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
      abi: FundManagerABI,
      functionName: "get_computer_balance",
    });

  const { data: gameContract } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: "gameContract",
  });

  // Watch for BetPlaced events
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    eventName: "BetPlaced",
    onLogs(logs) {
      if (logs.length > 0) {
        setLastBetAmount(logs[0].args.amount as bigint);
        refetchComputerBalance();
      }
    },
  });

  // Watch for FundsDeposited events
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    eventName: "FundsDeposited",
    onLogs() {
      refetchComputerBalance();
    },
  });

  // Watch for FundsWithdrawn events
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    eventName: "FundsWithdrawn",
    onLogs() {
      refetchComputerBalance();
    },
  });

  // Watch for WinningsAdded events
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    eventName: "WinningsAdded",
    onLogs(logs) {
      if (logs.length > 0) {
        setLastWinningsAmount(logs[0].args.amount as bigint);
        refetchComputerBalance();
      }
    },
  });

  // Watch for MaxBetLimitUpdated events
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    eventName: "MaxBetLimitUpdated",
    onLogs() {
      refetchMaxBetLimit();
    },
  });

  // Watch for GameContractUpdated events
  useWatchContractEvent({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    eventName: "GameContractUpdated",
    onLogs() {
      // Could refetch game contract or show notification
    },
  });

  return {
    maxBetLimit: maxBetLimit as bigint,
    owner: owner as string,
    computerBalance: computerBalance as bigint,
    gameContract: gameContract as string,
    lastBetAmount,
    lastWinningsAmount,
    refetchComputerBalance,
    refetchMaxBetLimit,
  };
}
