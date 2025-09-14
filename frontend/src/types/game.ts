export type Move = 0 | 1 | 2; // Rock, Paper, Scissors

export type GameState = 0 | 1 | 2; // Not Started, In Progress, Completed

export interface GameStatus {
  state: GameState;
  totalRounds: bigint;
  currentRound: bigint;
  playerWins: bigint;
  computerWins: bigint;
  playerBet: bigint;
  computerBet: bigint;
  totalPot: bigint;
}

export interface MoveHistory {
  playerMoves: bigint[];
  computerMoves: bigint[];
}

export interface GameRound {
  round: number;
  playerMove: Move;
  computerMove: Move;
  result: string;
}
