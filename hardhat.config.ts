import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    aeron: {
      url: "https://testnet-rpc.areon.network/",
      chainId: 462,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
      // 1001
    },
    artela: {
      url: "https://betanet-rpc1.artela.network/",
      chainId: 11822,
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
      // 1001
    },
  },
};

export default config;
