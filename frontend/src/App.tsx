import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useAccount } from "wagmi";
import { config } from "./wagmi.config";
import { WalletConnect } from "./components/WalletConnect";
import { BettingPanel } from "./components/BettingPanel";
import { GameBoard } from "./components/GameBoard";
import { GameHistory } from "./components/GameHistory";
import { useTournament } from "./hooks/useTournament";
import { GAME_STATES } from "./utils/constants";
import { FundsBar } from "./components/FundsBar";

const queryClient = new QueryClient();

function GameInterface() {
  const { address, isConnected } = useAccount();
  const { gameStatus } = useTournament(address);

  const canStartNewGame =
    !gameStatus || gameStatus.state !== GAME_STATES.IN_PROGRESS;

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">
            🎮 Cross-VM Rock Paper Scissors
          </h1>
          <p className="text-gray-600">
            Powered by Fluent's Blended Execution • Rust + Solidity
          </p>
        </div>

        {/* Wallet Connection */}
        <div className="max-w-md mx-auto mb-8">
          <WalletConnect />
        </div>

        {isConnected && (
          <>
            {/* Horizontal Funds Bar */}
            <div className="max-w-7xl mx-auto mb-6">
              <FundsBar />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 max-w-7xl mx-auto">
              {/* Left Column - Betting */}
              <div className="space-y-6">
                {canStartNewGame && <BettingPanel />}
                {/* Remove <GameStats /> from here */}
              </div>

              {/* Middle Column - Game Board */}
              <div className="lg:col-span-1">
                <GameBoard />
              </div>

              {/* Right Column - Game History */}
              <div>
                <GameHistory />
              </div>
            </div>
          </>
        )}

        {!isConnected && (
          <div className="text-center mt-12">
            <div className="bg-white rounded-lg p-8 max-w-md mx-auto border border-gray-200">
              <div className="text-6xl mb-4">🎲</div>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">
                Ready to Play?
              </h2>
              <p className="text-gray-600 mb-6">
                Connect your wallet to start playing Rock Paper Scissors against
                our AI. Place bets and win ETH on Fluent's revolutionary blended
                execution network!
              </p>
              <div className="grid grid-cols-3 gap-4 text-center text-sm text-gray-500">
                <div>
                  <div className="text-2xl mb-1">🪨</div>
                  <div>Rock</div>
                </div>
                <div>
                  <div className="text-2xl mb-1">📄</div>
                  <div>Paper</div>
                </div>
                <div>
                  <div className="text-2xl mb-1">✂️</div>
                  <div>Scissors</div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <GameInterface />
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
