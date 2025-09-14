// gblend configuration for Cross-VM Rock-Paper-Scissors Tournament

module.exports = {
  // Project name
  name: "Cross-VM-RPS-Tournament",
  
  // Network configuration
  networks: {
    fluent: {
      url: "https://rpc.dev.gblend.xyz/",
      chainId: 20993,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    testnet: {
      url: "https://rpc.dev.gblend.xyz/",
      chainId: 20993,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    }
  },
  
  // Contract paths
  contracts: {
    rust: ["rust-oracle/", "rust-computer-ai/"],
    solidity: "contracts/"
  },
  
  // Build configuration
  build: {
    rust: {
      target: "wasm32-unknown-unknown",
      release: true
    },
    solidity: {
      version: "0.8.20",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
