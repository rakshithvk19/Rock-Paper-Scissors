/**
 * Game Constants
 * Defines core game mechanics and configuration values
 */

// Move values for Rock-Paper-Scissors
export const MOVES = {
  ROCK: 0,
  PAPER: 1,
  SCISSORS: 2,
} as const;

// Human-readable move names
export const MOVE_NAMES = ['Rock', 'Paper', 'Scissors'];

// Visual representations of moves
export const MOVE_EMOJIS = ['🪨', '📄', '✂️'];

/**
 * Betting Configuration
 * Defines limits and options for bet amounts
 */
export const MIN_BET_ETH = 0.001;
export const MAX_BET_ETH = 0.1;
export const BET_STEP_ETH = 0.001;

// Pre-defined bet amounts for quick selection
export const QUICK_BET_OPTIONS = [
  { label: '0.001 ETH', value: 0.001 },
  { label: '0.01 ETH', value: 0.01 },
  { label: '0.05 ETH', value: 0.05 },
  { label: '0.1 ETH', value: 0.1 },
];

/**
 * Network Configuration
 * Fluent Devnet connection parameters
 */
export const FLUENT_CHAIN_ID = 20993;
export const FLUENT_RPC_URL = 'https://rpc.dev.gblend.xyz/';
export const FLUENT_EXPLORER_URL = 'https://blockscout.dev.gblend.xyz/';

/**
 * Contract Addresses
 * Deployed contract addresses on Fluent Devnet
 * Update these after deploying new contracts
 */
export const CONTRACT_ADDRESSES = {
  ORACLE: import.meta.env.VITE_ORACLE_ADDRESS || '',
  COMPUTER_AI: import.meta.env.VITE_COMPUTER_AI_ADDRESS || '',
  FUND_MANAGER: import.meta.env.VITE_FUND_MANAGER_ADDRESS || '',
  TOURNAMENT: import.meta.env.VITE_TOURNAMENT_ADDRESS || '',
};

/**
 * Game State Enumeration
 * Matches the contract's GameState enum
 */
export const GAME_STATES = {
  NOT_STARTED: 0,
  IN_PROGRESS: 1,
  COMPLETED: 2,
} as const;
