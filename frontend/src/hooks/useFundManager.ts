import { useReadContract } from "wagmi";
import { FundManagerABI } from "../contracts";
import { CONTRACT_ADDRESSES } from "../utils/constants";

export function useFundManager() {
  const { data: maxBetLimit } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: "get_max_bet_limit",
  });

  const { data: owner } = useReadContract({
    address: CONTRACT_ADDRESSES.FUND_MANAGER as `0x${string}`,
    abi: FundManagerABI,
    functionName: "owner",
  });

  return {
    maxBetLimit: maxBetLimit as bigint,
    owner: owner as string,
  };
}
