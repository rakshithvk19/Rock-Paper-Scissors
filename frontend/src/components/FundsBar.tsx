import { useAccount } from "wagmi";
import { useBalances } from "../hooks/useBalance";

export function FundsBar() {
  // Remove potAmount prop
  const { address } = useAccount();
  const { formattedWallet, formattedComputer, formattedPot } =
    useBalances(address);

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4 w-full">
      <div className="grid grid-cols-3 gap-6 text-center">
        {/* Player Balance */}
        <div className="flex flex-col">
          <span className="text-sm text-gray-500 mb-1">Your Balance</span>
          <span className="text-lg font-semibold text-green-600">
            {formattedWallet} ETH
          </span>
        </div>

        {/* Current Pot */}
        <div className="flex flex-col">
          <span className="text-sm text-gray-500 mb-1">Current Pot</span>
          <span className="text-lg font-semibold text-purple-600">
            {formattedPot} ETH
          </span>
        </div>

        {/* Computer Balance */}
        <div className="flex flex-col">
          <span className="text-sm text-gray-500 mb-1">Computer Balance</span>
          <span className="text-lg font-semibold text-blue-600">
            {formattedComputer} ETH
          </span>
        </div>
      </div>

      {/* Network indicator */}
      <div className="mt-3 pt-3 border-t border-gray-100 text-center">
        <span className="text-xs text-gray-500">
          Connected to Fluent Devnet
        </span>
      </div>
    </div>
  );
}
