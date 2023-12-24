import hre, { ethers } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { BigNumber, Contract, ContractTransaction } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

let snapshotId: string = "0x1";
export async function takeSnapshot() {
  snapshotId = await hre.ethers.provider.send("evm_snapshot", []);
}

export async function revertToSnapshot() {
  await hre.ethers.provider.send("evm_revert", [snapshotId]);
}

export const DECIMALS = 8;
export const WETH_VALUE = "221911200000"; //2219 usd
export const BTC_VALUE = "4360160000000"; //43601 usd

// Function to convert Ether to USD
export function convertToUSD(etherAmount, rateInWei, decimals) {
  const usdResult = etherAmount
    .mul(rateInWei)
    .div(BigNumber.from(10).pow(18))
    .div(BigNumber.from(10).pow(decimals));

  // Convert the result to an integer
  const formattedUSDResult = usdResult.toNumber(); // Convert to a regular JavaScript number
  const formattedEtherAmount = ethers.utils.formatUnits(etherAmount, 18);
  return `${formattedEtherAmount}  = ${formattedUSDResult} USD`;
}

export function convertUnits(val) {
  return `${ethers.utils.formatUnits(val, 18)} L-USD`;
}

export function getAddrs(): any {
  const json = fs.readFileSync("addresses.json", "utf8");
  const addrs = JSON.parse(json);
  return addrs;
}

export async function waitForTx(tx: Promise<ContractTransaction>) {
  await (await tx).wait();
}

export async function deployContract(tx: any): Promise<Contract> {
  const result = await tx;
  await result.deployTransaction.wait();
  return result;
}

export async function deployWithVerify(
  tx: any,
  args: any,
  contractPath: string
): Promise<Contract> {
  const deployedContract = await deployContract(tx);
  let count = 0;
  let maxTries = 8;
  const runtimeHRE = require("hardhat");
  while (true) {
    await delay(10000);
    try {
      console.log("Verifying contract at", deployedContract.address);
      await runtimeHRE.run("verify:verify", {
        address: deployedContract.address,
        constructorArguments: args,
        contract: contractPath,
      });
      break;
    } catch (error) {
      if (String(error).includes("Already Verified")) {
        console.log(
          `Already verified contract at ${contractPath} at address ${deployedContract.address}`
        );
        break;
      }
      if (++count == maxTries) {
        console.log(
          `Failed to verify contract at ${contractPath} at address ${deployedContract.address}, error: ${error}`
        );
        break;
      }
      console.log(`Retrying... Retry #${count}, last error: ${error}`);
    }
  }

  return deployedContract;
}

export async function initEnv(
  hre: HardhatRuntimeEnvironment
): Promise<SignerWithAddress[]> {
  const ethers = hre.ethers; // This allows us to access the hre (Hardhat runtime environment)'s injected ethers instance easily

  const accounts = await ethers.getSigners(); // This returns an array of the default signers connected to the hre's ethers instance
  const governance = accounts[1];
  const treasury = accounts[2];
  const user = accounts[3];

  return [governance, treasury, user];
}

async function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
