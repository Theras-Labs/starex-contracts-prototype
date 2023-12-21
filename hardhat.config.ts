import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
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
  },
};

export default config;
