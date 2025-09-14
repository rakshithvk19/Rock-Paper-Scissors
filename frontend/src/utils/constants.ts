// Game constants
export const MOVES = {
  ROCK: 0,
  PAPER: 1,
  SCISSORS: 2,
} as const;

export const MOVE_NAMES = ['Rock', 'Paper', 'Scissors'];
export const MOVE_EMOJIS = ['🪨', '📄', '✂️'];

// Betting constants
export const MIN_BET_ETH = 0.001;
export const MAX_BET_ETH = 0.1;
export const BET_STEP_ETH = 0.001;

// Quick bet options
export const QUICK_BET_OPTIONS = [
  { label: '0.001 ETH', value: 0.001 },
  { label: '0.01 ETH', value: 0.01 },
  { label: '0.05 ETH', value: 0.05 },
  { label: '0.1 ETH', value: 0.1 },
];

// Network constants
export const FLUENT_CHAIN_ID = 20993;
export const FLUENT_RPC_URL = 'https://rpc.dev.gblend.xyz/';
export const FLUENT_EXPLORER_URL = 'https://blockscout.dev.gblend.xyz/';

// Put actual deployed addresses here
export const CONTRACT_ADDRESSES = {
  ORACLE: '0x742d35Cc6634C0532925a3b8D54321B0a8Bc9b12', 
  COMPUTER_AI: '0x8ba1f109551bD432803012645Hac136c63F50429',
  FUND_MANAGER: '0xa0b86991c431e607f6f4c9cfe3b06f76e3fe1f50a',
  TOURNAMENT: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
};

// Game state constants
export const GAME_STATES = {
  NOT_STARTED: 0,
  IN_PROGRESS: 1,
  COMPLETED: 2,
} as const;
