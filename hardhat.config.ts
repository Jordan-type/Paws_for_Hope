import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import "hardhat-deploy";
import "dotenv/config";

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "api-key"
const SEPOLIA_ETHERSCAN_API_KEY = process.env.SEPOLIA_ETHERSCAN_API_KEY || "api-key"
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY || "api-key"

// Import MNEMONIC or single private key
const MNEMONIC = process.env.MNEMONIC || "your mnemonic"
const WALLET_PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY
 

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0, // First account in the list
    },
  },
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },

  //   SepoliaCypherium: {
  //     url: 'https://pubnodestest.cypherium.io',
  //     accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
  //     gasPrice: 1750809638,
  //     chainId: 16164,
  //  },

  //   cypheriumDev: {
  //     url: "http://127.0.0.1:8000",
  //     accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
  //     network_id: "16164",
  //     gasPrice: 0,
  //     chainId: 16163,
  //   },

    lisk: {
      url: "https://rpc.api.lisk.com",
      accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
      gasPrice: 1000000000,
    },

    "lisk-sepolia": {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
      gasPrice: 1000000000,
    },

    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_SEPOLIA}`,
      accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
    },

    ethereum: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_MAIN}`,
      accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
      chainId: 44787,
    },

    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
      chainId: 44787,
    },

    celo: {
      url: "https://forno.celo.org",
      accounts: WALLET_PRIVATE_KEY ? [WALLET_PRIVATE_KEY] : { mnemonic: MNEMONIC },
      chainId: 42220,
    },
  },

  // ethereum - celo - explorer API keys
  etherscan: {
    // Use "123" as a placeholder, because Blockscout doesn't need a real API key, and Hardhat will complain if this property isn't set.
    apiKey: {
      mainet: ETHERSCAN_API_KEY || '',
      sepolia: SEPOLIA_ETHERSCAN_API_KEY || '',
      baseMainet: BSCSCAN_API_KEY || '',      
      bscTestnet: BSCSCAN_API_KEY || '',
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
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
};

export default config;
