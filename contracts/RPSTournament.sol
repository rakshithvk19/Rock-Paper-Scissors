// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IRandomOracle.sol";

/// @title RPSTournament
/// @notice Rock-Paper-Scissors tournament with cross-VM oracle integration
/// @dev Demonstrates Fluent's blended execution with Rust oracle calls
contract RPSTournament {
    IRandomOracle public immutable oracle;
    
    // Game states
    enum GameState { NOT_STARTED, IN_PROGRESS, COMPLETED }
    enum Move { ROCK, PAPER, SCISSORS }
    enum RoundResult { DRAW, PLAYER_WIN, COMPUTER_WIN }
    enum GameResult { ONGOING, PLAYER_CHAMPION, COMPUTER_CHAMPION }
    
    struct Tournament {
        address player;
        uint256 totalRounds;
        uint256 currentRound;
        uint256 playerWins;
        uint256 computerWins;
        uint256 draws;
        GameState state;
        GameResult result;
        uint256 gameSeed;
        uint256[] playerMoves;
        uint256[] computerMoves;
        uint256[] roundResults;
        uint256 startTime;
        uint256 endTime;
    }
    
    // State variables
    mapping(address => Tournament) public tournaments;
    mapping(address => uint256[]) public playerHistory;
    uint256 public totalGamesPlayed;
    uint256 public totalRoundsPlayed;
    
    // Leaderboard tracking
    address[] public players;
    mapping(address => bool) public hasPlayed;
    
    // Events
    event TournamentStarted(address indexed player, uint256 totalRounds, uint256 gameSeed);
    event RoundPlayed(
        address indexed player, 
        uint256 round, 
        uint256 playerMove, 
        uint256 computerMove, 
        RoundResult result
    );
    event TournamentCompleted(
        address indexed player, 
        GameResult result, 
        uint256 playerWins, 
        uint256 computerWins,
        uint256 duration
    );
    
    // Custom errors for gas optimization
    error TournamentInProgress();
    error NoActiveTournament();
    error TournamentAlreadyCompleted();
    error InvalidMove();
    
    constructor(address _oracle) {
        oracle = IRandomOracle(_oracle);
    }
    
    /// @notice Start a new tournament
    /// @dev Calls Rust oracle to determine number of rounds
    function startTournament() external {
        if (tournaments[msg.sender].state == GameState.IN_PROGRESS) {
            revert TournamentInProgress();
        }
        
        // Generate unique seed for this game
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender, 
                    block.timestamp, 
                    block.number,
                    totalGamesPlayed
                )
            )
        );
        
        // Cross-VM call to Rust oracle for round determination
        uint256 rounds = oracle.generate_rounds(seed);
        
        // Initialize tournament
        delete tournaments[msg.sender]; // Clear previous tournament
        
        Tournament storage tourney = tournaments[msg.sender];
        tourney.player = msg.sender;
        tourney.totalRounds = rounds;
        tourney.state = GameState.IN_PROGRESS;
        tourney.result = GameResult.ONGOING;
        tourney.gameSeed = seed;
        tourney.startTime = block.timestamp;
        
        // Track player
        if (!hasPlayed[msg.sender]) {
            players.push(msg.sender);
            hasPlayed[msg.sender] = true;
        }
        
        totalGamesPlayed++;
        playerHistory[msg.sender].push(totalGamesPlayed);
        
        emit TournamentStarted(msg.sender, rounds, seed);
    }
    
    /// @notice Play a round in the tournament
    /// @param _playerMove The player's move choice
    /// @dev Makes multiple cross-VM calls to Rust oracle
    function playRound(Move _playerMove) external {
        Tournament storage tourney = tournaments[msg.sender];
        
        if (tourney.state != GameState.IN_PROGRESS) {
            revert NoActiveTournament();
        }
        if (tourney.currentRound >= tourney.totalRounds) {
            revert TournamentAlreadyCompleted();
        }
        
        uint256 playerMove = uint256(_playerMove);
        if (playerMove > 2) {
            revert InvalidMove();
        }
        
        // Cross-VM call: Get computer's move from Rust oracle
        uint256 computerMove = oracle.get_rps_choice(tourney.currentRound, tourney.gameSeed);
        
        // Cross-VM call: Determine round winner
        uint256 roundResult = oracle.check_round_winner(playerMove, computerMove);
        
        // Store round data
        tourney.playerMoves.push(playerMove);
        tourney.computerMoves.push(computerMove);
        tourney.roundResults.push(roundResult);
        tourney.currentRound++;
        totalRoundsPlayed++;
        
        // Update scores
        if (roundResult == 1) {
            tourney.playerWins++;
            emit RoundPlayed(msg.sender, tourney.currentRound, playerMove, computerMove, RoundResult.PLAYER_WIN);
        } else if (roundResult == 2) {
            tourney.computerWins++;
            emit RoundPlayed(msg.sender, tourney.currentRound, playerMove, computerMove, RoundResult.COMPUTER_WIN);
        } else {
            tourney.draws++;
            emit RoundPlayed(msg.sender, tourney.currentRound, playerMove, computerMove, RoundResult.DRAW);
        }
        
        // Check for tournament completion
        uint256 majorityNeeded = oracle.get_majority_threshold(tourney.totalRounds);
        
        if (tourney.playerWins >= majorityNeeded || 
            tourney.computerWins >= majorityNeeded || 
            tourney.currentRound >= tourney.totalRounds) {
            
            // Cross-VM call: Determine final champion
            uint256 champion = oracle.determine_champion(
                tourney.playerWins, 
                tourney.computerWins, 
                tourney.totalRounds
            );
            
            if (champion == 1) {
                tourney.result = GameResult.PLAYER_CHAMPION;
            } else if (champion == 2) {
                tourney.result = GameResult.COMPUTER_CHAMPION;
            }
            
            tourney.state = GameState.COMPLETED;
            tourney.endTime = block.timestamp;
            
            emit TournamentCompleted(
                msg.sender, 
                tourney.result, 
                tourney.playerWins, 
                tourney.computerWins,
                tourney.endTime - tourney.startTime
            );
        }
    }
    
    /// @notice Get current tournament status
    function getTournamentStatus(address player) external view returns (
        GameState state,
        uint256 totalRounds,
        uint256 currentRound,
        uint256 playerWins,
        uint256 computerWins,
        uint256 draws,
        GameResult result
    ) {
        Tournament memory t = tournaments[player];
        return (t.state, t.totalRounds, t.currentRound, t.playerWins, t.computerWins, t.draws, t.result);
    }
    
    /// @notice Get detailed round history
    function getRoundHistory(address player) external view returns (
        uint256[] memory playerMoves,
        uint256[] memory computerMoves,
        uint256[] memory results
    ) {
        Tournament memory t = tournaments[player];
        return (t.playerMoves, t.computerMoves, t.roundResults);
    }
    
    /// @notice Convert move to string
    function getMoveString(uint256 move) public pure returns (string memory) {
        if (move == 0) return "Rock";
        if (move == 1) return "Paper";
        if (move == 2) return "Scissors";
        return "Invalid";
    }
    
    /// @notice Get player statistics
    function getPlayerStats(address player) external view returns (
        uint256 gamesPlayed,
        uint256 currentWins,
        uint256 currentLosses,
        bool inTournament
    ) {
        Tournament memory t = tournaments[player];
        return (
            playerHistory[player].length,
            t.playerWins,
            t.computerWins,
            t.state == GameState.IN_PROGRESS
        );
    }
    
    /// @notice Get global statistics
    function getGlobalStats() external view returns (
        uint256 _totalGamesPlayed,
        uint256 _totalRoundsPlayed,
        uint256 _totalPlayers
    ) {
        return (totalGamesPlayed, totalRoundsPlayed, players.length);
    }
}