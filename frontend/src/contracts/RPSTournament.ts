export const RPSTournamentABI = 
[
  {
    "type": "constructor",
    "inputs": [
      {
        "name": "_oracle",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_computerAI",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_fundManager",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "receive",
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "computerAI",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "contract IComputerAI"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "fundManager",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "contract IFundManager"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "games",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "player",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "totalRounds",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "currentRound",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "playerWins",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "computerWins",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "state",
        "type": "uint8",
        "internalType": "enum RPSTournament.GameState"
      },
      {
        "name": "gameSeed",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "playerBet",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "computerBet",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "totalPot",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getGameStatus",
    "inputs": [
      {
        "name": "player",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "state",
        "type": "uint8",
        "internalType": "enum RPSTournament.GameState"
      },
      {
        "name": "totalRounds",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "currentRound",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "playerWins",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "computerWins",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "playerBet",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "computerBet",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "totalPot",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getMoveHistory",
    "inputs": [
      {
        "name": "player",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "playerMoves",
        "type": "uint256[]",
        "internalType": "uint256[]"
      },
      {
        "name": "computerMoves",
        "type": "uint256[]",
        "internalType": "uint256[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "oracle",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "contract IRandomOracle"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "playRound",
    "inputs": [
      {
        "name": "playerMove",
        "type": "uint8",
        "internalType": "enum RPSTournament.Move"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "startGame",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "event",
    "name": "GameCompleted",
    "inputs": [
      {
        "name": "player",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "result",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "playerWins",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "computerWins",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "payout",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "GameStarted",
    "inputs": [
      {
        "name": "player",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "totalRounds",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "playerBet",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoundPlayed",
    "inputs": [
      {
        "name": "player",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "round",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "playerMove",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum RPSTournament.Move"
      },
      {
        "name": "computerMove",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum RPSTournament.Move"
      },
      {
        "name": "result",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  }
]as const;
