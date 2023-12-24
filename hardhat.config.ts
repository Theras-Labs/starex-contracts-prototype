import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();
const TEST_SNAPSHOT_ID = "0x1";
const HARDHATEVM_CHAINID = 31337;
const DEFAULT_BLOCK_GAS_LIMIT = 124500000;
const MNEMONIC_PATH = "m/44'/60'/0'/0";
const MNEMONIC = process.env.MNEMONIC || "";
const MAINNET_FORK = process.env.MAINNET_FORK === "true";
const TRACK_GAS = process.env.TRACK_GAS === "true";
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY || "";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: "https://ethereum-sepolia.publicnode.com",
      chainId: 11155111,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
      // 1001
    },
    goerli: {
      url: "https://ethereum-goerli.publicnode.com",
      chainId: 5,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
      // 1001
      gas: DEFAULT_BLOCK_GAS_LIMIT,
      gasPrice: 80000000000,
    },
    klaytn: {
      url: "https://public-en-baobab.klaytn.net",
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
      // 1001
    },
    inevm: {
      url: "https://inevm-rpc.caldera.dev",
      chainId: 1738,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
      // 1738
    },
    viction: {
      url: "https://rpc-testnet.viction.xyz",
      chainId: 89,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
    },
    aeron: {
      url: "https://testnet-rpc.areon.network/",
      chainId: 462,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
    },
    hardhat: {
      hardfork: "london",
      blockGasLimit: DEFAULT_BLOCK_GAS_LIMIT,
      allowUnlimitedContractSize: true, // UNOPTIMIZED
      gas: DEFAULT_BLOCK_GAS_LIMIT,
      gasPrice: 80000000000,
      chainId: HARDHATEVM_CHAINID,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      mining: {
        mempool: {
          order: "priority",
          // order: "fifo"
        },
      },
      // accounts: accounts.map(({ secretKey, balance }: { secretKey: string; balance: string }) => ({
      //   privateKey: secretKey,
      //   balance,
      // })),
      // forking: mainnetFork,
    },
  },
};

export default config;
