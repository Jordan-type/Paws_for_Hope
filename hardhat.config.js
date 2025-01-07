require("@nomicfoundation/hardhat-ignition/modules");
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },

    SepoliaCypherium: {
      url: 'https://pubnodestest.cypherium.io',
      accounts: [privateKey1],
      gasPrice: 1750809638,
      chainId: 16164,
   },

    cypheriumDev: {
      url: "http://127.0.0.1:8000",
      accounts: [privateKey1],
      network_id: "16164",
      gasPrice: 0,
      chainId: 16163,
    },

    lisk: {
      url: "https://rpc.api.lisk.com",
      accounts: [process.env.WALLET_PRIVATE_KEY],
      gasPrice: 1000000000,
    },

    "lisk-sepolia": {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: [process.env.WALLET_PRIVATE_KEY],
      gasPrice: 1000000000,
    },

    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_SEPOLIA}`,
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },

    ethereum: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_MAIN}`,
      accounts: [process.env.WALLET_PRIVATE_KEY],
      chainId: 44787,
    },

    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [process.env.WALLET_PRIVATE_KEY],
      chainId: 44787,
    },

    celo: {
      url: "https://forno.celo.org",
      accounts: [process.env.WALLET_PRIVATE_KEY],
      chainId: 42220,
    },
  },

  // ethereum - celo - explorer API keys
  etherscan: {
    // Use "123" as a placeholder, because Blockscout doesn't need a real API key, and Hardhat will complain if this property isn't set.
    apiKey: {
      "lisk-sepolia": "123",
    },
    customChains: [
      {
        network: "lisk-sepolia",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api",
          browserURL: "https://sepolia-blockscout.lisk.com",
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
  },

  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
};
