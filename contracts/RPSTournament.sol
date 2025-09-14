// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IRandomOracle.sol";
import "./interfaces/IComputerAI.sol";
import "./interfaces/IFundManager.sol";

/// @title RPSTournament
/// @notice Rock-Paper-Scissors tournament with betting
contract RPSTournament {
    IRandomOracle public immutable oracle;
    IComputerAI public immutable computerAI;
    IFundManager public immutable fundManager;
    
    enum Move { ROCK, PAPER, SCISSORS }
    enum GameState { NOT_STARTED, IN_PROGRESS, COMPLETED }
    
    struct Game {
        address player;
        uint256 totalRounds;
        uint256 currentRound;
        uint256 playerWins;
        uint256 computerWins;
        GameState state;
        uint256 gameSeed;
        uint256[] playerMoves;
        uint256[] computerMoves;
        uint256 playerBet;
        uint256 computerBet;
        uint256 totalPot;
    }
    
    mapping(address => Game) public games;
    
    event GameStarted(address indexed player, uint256 totalRounds, uint256 playerBet);
    event RoundPlayed(
        address indexed player, 
        uint256 round, 
        Move playerMove, 
        Move computerMove, 
        string result
    );
    event GameCompleted(
        address indexed player, 
        string result, 
        uint256 playerWins, 
        uint256 computerWins,
        uint256 payout
    );
    
    constructor(address _oracle, address _computerAI, address _fundManager) {
        oracle = IRandomOracle(_oracle);
        computerAI = IComputerAI(_computerAI);
        fundManager = IFundManager(_fundManager);
    }
    
    /// @notice Start a new game with betting
    function startGame() external payable {
        require(games[msg.sender].state != GameState.IN_PROGRESS, "Game in progress");
        require(msg.value > 0, "Must place a bet");
        
        uint256 seed = oracle.get_random_seed();
        uint256 rounds = oracle.generate_rounds(seed);
        
        // Get computer's betting decision
        uint256 computerBetAmount = computerAI.get_betting_advice(0, 0, rounds, 0);
        
        // Ensure computer can afford the bet
        require(fundManager.can_afford_bet(computerBetAmount), "Computer cannot afford bet");
        require(fundManager.computer_bet(computerBetAmount), "Computer bet failed");
        
        games[msg.sender] = Game({
            player: msg.sender,
            totalRounds: rounds,
            currentRound: 0,
            playerWins: 0,
            computerWins: 0,
            state: GameState.IN_PROGRESS,
            gameSeed: seed,
            playerMoves: new uint256[](0),
            computerMoves: new uint256[](0),
            playerBet: msg.value,
            computerBet: computerBetAmount,
            totalPot: msg.value + computerBetAmount
        });
        
        emit GameStarted(msg.sender, rounds, msg.value);
    }
    
    /// @notice Play a round
    function playRound(Move playerMove) external {
        Game storage game = games[msg.sender];
        require(game.state == GameState.IN_PROGRESS, "No active game");
        require(game.currentRound < game.totalRounds, "Game completed");
        
        // Get computer move from AI
        Move computerMove = Move(computerAI.get_move(
            game.currentRound, 
            game.gameSeed, 
            game.playerMoves
        ));
        
        // Store moves
        game.playerMoves.push(uint256(playerMove));
        game.computerMoves.push(uint256(computerMove));
        
        // Determine winner
        string memory result;
        if (playerMove == computerMove) {
            result = "Draw";
        } else if (_playerWins(playerMove, computerMove)) {
            game.playerWins++;
            result = "Player wins";
        } else {
            game.computerWins++;
            result = "Computer wins";
        }
        
        game.currentRound++;
        
        emit RoundPlayed(msg.sender, game.currentRound, playerMove, computerMove, result);
        
        // Check if game is complete
        if (game.currentRound >= game.totalRounds) {
            _completeGame(game);
        }
    }
    
    /// @notice Complete the game and distribute payouts
    function _completeGame(Game storage game) private {
        game.state = GameState.COMPLETED;
        
        uint256 payout = 0;
        string memory result;
        
        if (game.playerWins > game.computerWins) {
            // Player wins - gets the full pot
            result = "Player Champion!";
            payout = game.totalPot;
            payable(game.player).transfer(payout);
        } else if (game.computerWins > game.playerWins) {
            // Computer wins - winnings go back to fund manager
            result = "Computer Champion!";
            fundManager.addWinnings(game.totalPot);
        } else {
            // Draw - both get their original bets back
            result = "Draw!";
            payout = game.playerBet;
            payable(game.player).transfer(payout);
            fundManager.addWinnings(game.computerBet);
        }
        
        emit GameCompleted(game.player, result, game.playerWins, game.computerWins, payout);
    }
    
    /// @notice Check if player wins a round
    function _playerWins(Move playerMove, Move computerMove) private pure returns (bool) {
        return (playerMove == Move.ROCK && computerMove == Move.SCISSORS) ||
               (playerMove == Move.PAPER && computerMove == Move.ROCK) ||
               (playerMove == Move.SCISSORS && computerMove == Move.PAPER);
    }
    
    /// @notice Get current game status
    function getGameStatus(address player) external view returns (
        GameState state,
        uint256 totalRounds,
        uint256 currentRound,
        uint256 playerWins,
        uint256 computerWins,
        uint256 playerBet,
        uint256 computerBet,
        uint256 totalPot
    ) {
        Game memory game = games[player];
        return (
            game.state, 
            game.totalRounds, 
            game.currentRound, 
            game.playerWins, 
            game.computerWins,
            game.playerBet,
            game.computerBet,
            game.totalPot
        );
    }
    
    /// @notice Get move history for a player
    function getMoveHistory(address player) external view returns (
        uint256[] memory playerMoves,
        uint256[] memory computerMoves
    ) {
        Game memory game = games[player];
        return (game.playerMoves, game.computerMoves);
    }
}
