// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IRandomOracle.sol";
import "./interfaces/IComputerAI.sol";
import "./interfaces/IFundManager.sol";
import "./interfaces/IRPSTournament.sol";

/**
 * @title RPSTournament
 * @notice Rock-Paper-Scissors tournament with cross-VM betting functionality
 * @dev Implements tournament logic with Rust oracles and Solidity fund management
 * @author rakshithvk19
 * @custom:security-contact security@fluent.xyz
 */
contract RPSTournament is IRPSTournament {
    // ============ IMMUTABLE STATE ============

    /// @notice Random number generation oracle (Rust contract)
    IRandomOracle public immutable oracle;

    /// @notice Computer AI decision making (Rust contract)
    IComputerAI public immutable computerAI;

    /// @notice Fund management for computer betting (Solidity contract)
    IFundManager public immutable fundManager;

    // ============ CUSTOM ERRORS ============

    /// @notice Thrown when trying to start game while another is in progress
    error GameAlreadyInProgress();

    /// @notice Thrown when no ETH is sent with startGame()
    error MustPlaceBet();

    /// @notice Thrown when trying to play round without active game
    error NoActiveGame();

    /// @notice Thrown when trying to play beyond total rounds
    error GameAlreadyCompleted();

    /// @notice Thrown when computer cannot afford to place bet
    error ComputerBetFailed();

    /// @notice Thrown when ETH transfer fails
    error TransferFailed();

    // ============ EVENTS ============

    /**
     * @notice Emitted when a new game starts
     * @param player Address of the player starting the game
     * @param totalRounds Number of rounds in this tournament (1-10)
     * @param playerBet Amount of ETH bet by player (wei)
     * @param computerBet Amount of ETH bet by computer (wei)
     */
    event GameStarted(
        address indexed player,
        uint256 totalRounds,
        uint256 playerBet,
        uint256 computerBet
    );

    /**
     * @notice Emitted after each round is played
     * @param player Address of the player
     * @param round Round number (1-indexed for display)
     * @param playerMove Move chosen by player
     * @param computerMove Move chosen by computer AI
     * @param result Round outcome ("Draw", "Player wins", "Computer wins")
     */
    event RoundPlayed(
        address indexed player,
        uint256 indexed round,
        Move playerMove,
        Move computerMove,
        string result
    );

    /**
     * @notice Emitted when game completes and payouts are distributed
     * @param player Address of the player
     * @param result Final game outcome
     * @param playerWins Total rounds won by player
     * @param computerWins Total rounds won by computer
     * @param payout Amount paid to player (0 if computer won)
     */
    event GameCompleted(
        address indexed player,
        string result,
        uint256 playerWins,
        uint256 computerWins,
        uint256 payout
    );

    // ============ STRUCTS ============

    /**
     * @notice Game state for a single tournament
     * @dev Optimized for gas efficiency - no redundant data storage
     * @param totalRounds Total rounds for this game (determined by oracle)
     * @param currentRound Rounds completed (0-indexed)
     * @param playerWins Number of rounds won by player
     * @param computerWins Number of rounds won by computer
     * @param state Current game state enum
     * @param gameSeed Random seed for AI decision making
     * @param playerBet ETH amount bet by player (wei)
     * @param computerBet ETH amount bet by computer (wei)
     */
    struct Game {
        uint256 totalRounds;
        uint256 currentRound;
        uint256 playerWins;
        uint256 computerWins;
        GameState state;
        uint256 gameSeed;
        uint256 playerBet;
        uint256 computerBet;
    }

    // ============ STATE VARIABLES ============

    /// @notice Maps player addresses to their current game state
    mapping(address => Game) public games;

    // ============ CONSTRUCTOR ============

    /**
     * @notice Deploy tournament with required contract dependencies
     * @dev All contracts must be deployed and functional before tournament deployment
     * @param _oracle Address of random oracle contract (Rust/WASM)
     * @param _computerAI Address of computer AI contract (Rust/WASM)
     * @param _fundManager Address of fund manager contract (Solidity)
     */
    constructor(address _oracle, address _computerAI, address _fundManager) {
        oracle = IRandomOracle(_oracle);
        computerAI = IComputerAI(_computerAI);
        fundManager = IFundManager(_fundManager);
    }

    // ============ EXTERNAL FUNCTIONS ============

    /**
     * @inheritdoc IRPSTournament
     * @dev Cross-VM interaction: Calls Rust oracle for randomness and AI for betting advice
     */
    function startGame() external payable override {
        if (games[msg.sender].state == GameState.IN_PROGRESS) {
            revert GameAlreadyInProgress();
        }
        if (msg.value == 0) {
            revert MustPlaceBet();
        }

        // Get random seed and tournament length from Rust oracle
        uint256 seed = oracle.get_random_seed();
        uint256 rounds = oracle.generate_rounds(seed);

        // Get computer's betting strategy from Rust AI
        uint256 computerBetAmount = computerAI.get_betting_advice(
            0,
            0,
            rounds,
            0
        );

        // Computer places bet through fund manager
        if (!fundManager.computer_bet(computerBetAmount)) {
            revert ComputerBetFailed();
        }

        // Initialize game state
        games[msg.sender] = Game({
            totalRounds: rounds,
            currentRound: 0,
            playerWins: 0,
            computerWins: 0,
            state: GameState.IN_PROGRESS,
            gameSeed: seed,
            playerBet: msg.value,
            computerBet: computerBetAmount
        });

        emit GameStarted(msg.sender, rounds, msg.value, computerBetAmount);
    }

    /**
     * @inheritdoc IRPSTournament
     * @dev Cross-VM interaction: Calls Rust AI for computer move decision
     */
    function playRound(Move playerMove) external override {
        Game storage game = games[msg.sender];

        if (game.state != GameState.IN_PROGRESS) {
            revert NoActiveGame();
        }
        if (game.currentRound >= game.totalRounds) {
            revert GameAlreadyCompleted();
        }

        // Get computer move from Rust AI (pass empty history since we use events)
        Move computerMove = Move(
            computerAI.get_move(
                game.currentRound,
                game.gameSeed,
                new uint256[](0)
            )
        );

        // Determine round winner
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

        emit RoundPlayed(
            msg.sender,
            game.currentRound,
            playerMove,
            computerMove,
            result
        );

        // Complete game if all rounds finished
        if (game.currentRound >= game.totalRounds) {
            _completeGame(game);
        }
    }

    /**
     * @inheritdoc IRPSTournament
     */
    function getGameStatus(
        address player
    )
        external
        view
        override
        returns (
            GameState state,
            uint256 totalRounds,
            uint256 currentRound,
            uint256 playerWins,
            uint256 computerWins,
            uint256 playerBet,
            uint256 computerBet,
            uint256 totalPot
        )
    {
        Game storage game = games[player];
        return (
            game.state,
            game.totalRounds,
            game.currentRound,
            game.playerWins,
            game.computerWins,
            game.playerBet,
            game.computerBet,
            game.playerBet + game.computerBet
        );
    }

    /**
     * @inheritdoc IRPSTournament
     */
    function getMoveHistory(
        address
    )
        external
        pure
        override
        returns (uint256[] memory playerMoves, uint256[] memory computerMoves)
    {
        // Return empty arrays - clients should query RoundPlayed events
        return (new uint256[](0), new uint256[](0));
    }

    // ============ INTERNAL FUNCTIONS ============

    /**
     * @notice Complete the tournament and distribute payouts
     * @dev Internal function to handle final game resolution and fund distribution
     * @param game Reference to the game being completed
     */
    function _completeGame(Game storage game) internal {
        game.state = GameState.COMPLETED;

        uint256 totalPot = game.playerBet + game.computerBet;
        uint256 playerPayout = 0;
        string memory result;

        if (game.playerWins > game.computerWins) {
            // Player victory - receives full pot
            result = "Player Champion!";
            playerPayout = totalPot;

            (bool success, ) = payable(msg.sender).call{value: totalPot}("");
            if (!success) revert TransferFailed();
        } else if (game.computerWins > game.playerWins) {
            // Computer victory - fund manager receives full pot
            result = "Computer Champion!";
            fundManager.addWinnings{value: totalPot}(totalPot);
        } else {
            // Draw - each gets original bet back
            result = "Draw!";
            playerPayout = game.playerBet;

            // Return player's bet
            (bool playerSuccess, ) = payable(msg.sender).call{
                value: game.playerBet
            }("");
            if (!playerSuccess) revert TransferFailed();

            // Return computer's bet to fund manager
            fundManager.addWinnings{value: game.computerBet}(game.computerBet);
        }

        emit GameCompleted(
            msg.sender,
            result,
            game.playerWins,
            game.computerWins,
            playerPayout
        );
    }

    /**
     * @notice Determine if player wins the round
     * @dev Pure function implementing Rock-Paper-Scissors win conditions
     * @param playerMove Player's chosen move
     * @param computerMove Computer's chosen move
     * @return true if player wins, false otherwise
     */
    function _playerWins(
        Move playerMove,
        Move computerMove
    ) internal pure returns (bool) {
        return
            (playerMove == Move.ROCK && computerMove == Move.SCISSORS) ||
            (playerMove == Move.PAPER && computerMove == Move.ROCK) ||
            (playerMove == Move.SCISSORS && computerMove == Move.PAPER);
    }

    // ============ RECEIVE FUNCTION ============

    /**
     * @notice Allow contract to receive ETH from fund manager
     * @dev Required for receiving computer bet refunds and winnings
     */
    receive() external payable {}
}
