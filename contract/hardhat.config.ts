import * as dotenv from "dotenv";
dotenv.config();
import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition-ethers";
import "@typechain/hardhat";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";

const deployerPrivateKey =
  process.env.DEPLOYER_PRIVATE_KEY ?? "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const baseSepoliaApiKey = process.env.BASE_SEPOLIA_API_KEY ?? "";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.28",
        settings: {
          viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    "base-sepolia": {
      url: "https://sepolia.base.org",
      accounts: [deployerPrivateKey],
    },
    "soneium-minato": {
      url: "https://rpc.minato.soneium.org/",
      accounts: [deployerPrivateKey],
      chainId: 1946,
    },
  },
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },
  etherscan: {
    apiKey: {
      'base-sepolia': baseSepoliaApiKey
    },
    customChains: [
      {
        network: "base-sepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://base-sepolia.blockscout.com/api",
          browserURL: "https://base-sepolia.blockscout.com/",
          // apiURL: "https://api-sepolia.basescan.org/api",
          // browserURL: "https://sepolia.basescan.org",
        }
      }
    ]
  },
  sourcify: {
    enabled: false,
  },
};

export default config;
