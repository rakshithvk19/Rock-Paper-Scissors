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
  ORACLE: import.meta.env.VITE_ORACLE_ADDRESS || '',
  COMPUTER_AI: import.meta.env.VITE_COMPUTER_AI_ADDRESS || '',
  FUND_MANAGER: import.meta.env.VITE_FUND_MANAGER_ADDRESS || '',
  TOURNAMENT: import.meta.env.VITE_TOURNAMENT_ADDRESS || '',
};

// Game state constants
export const GAME_STATES = {
  NOT_STARTED: 0,
  IN_PROGRESS: 1,
  COMPLETED: 2,
} as const;
