/**
 * Move type representing the three possible game moves
 * 0 = Rock, 1 = Paper, 2 = Scissors
 */
export type Move = 0 | 1 | 2;

/**
 * GameState type representing the game lifecycle
 * 0 = Not Started, 1 = In Progress, 2 = Completed
 */
export type GameState = 0 | 1 | 2;

/**
 * GameStatus interface
 * Complete game state information returned from the smart contract
 */
export interface GameStatus {
  state: GameState;          // Current game state
  totalRounds: bigint;        // Total number of rounds in this game
  currentRound: bigint;       // Number of rounds completed
  playerWins: bigint;         // Player's win count
  computerWins: bigint;       // Computer's win count
  playerBet: bigint;          // Amount bet by player (wei)
  computerBet: bigint;        // Amount bet by computer (wei)
  totalPot: bigint;           // Total pot amount (wei)
}

/**
 * MoveHistory interface
 * @deprecated Use RoundPlayed events instead
 * This interface is kept for compatibility but returns empty arrays
 */
export interface MoveHistory {
  playerMoves: bigint[];
  computerMoves: bigint[];
}

/**
 * GameRound interface
 * Represents a single round of play
 */
export interface GameRound {
  round: number;           // Round number (1-indexed)
  playerMove: Move;         // Player's move for this round
  computerMove: Move;       // Computer's move for this round
  result: string;           // Round result ("Player wins", "Computer wins", "Draw")
}
