import { task } from "hardhat/config";
import fs from "fs";
import { deployContract, waitForTx } from "./helpers/utils";
import {
  AssetContract__factory,
  EXGEM__factory,
  ExPoints__factory,
  ManagerClaim__factory,
  NFT_starship__factory,
  PlayExplore__factory,
  SeasonPASS__factory,
  Shop__factory,
  TICKET__factory,
} from "../typechain-types";
import { BigNumber, Contract, Signer } from "ethers";
import "@nomiclabs/hardhat-ethers";
import { ethers } from "hardhat";

// task("full-deploy", "deploys the entire STAR EX").setAction(async ({}, hre) => {
async function main() {
  //   const ethers = hre.ethers;
  //   const accounts = await ethers.getSigners();
  //   const deployer = accounts[0];
  const [deployer] = await ethers.getSigners();

  console.log(deployer.address, "deployer");
  console.log("\n\t-- Deploying CONTRACTS --");

  let deployerNonce = await ethers.provider.getTransactionCount(
    deployer.address
  );

  const EX_POINTS = await deployContract(
    new ExPoints__factory(deployer).deploy(deployer.address, {
      nonce: deployerNonce++,
    })
  );
  const TOKEN_GEM = await deployContract(
    new EXGEM__factory(deployer).deploy(deployer.address, {
      nonce: deployerNonce++,
    })
  );
  const NFT_ASSET = await deployContract(
    new AssetContract__factory(deployer).deploy(deployer.address, {
      nonce: deployerNonce++,
    })
  );
  const NFT_TICKET = await deployContract(
    new TICKET__factory(deployer).deploy(deployer.address, {
      nonce: deployerNonce++,
    })
  );
  const NFT_PASS = await deployContract(
    new SeasonPASS__factory(deployer).deploy(deployer.address, {
      nonce: deployerNonce++,
    })
  );

  const NFT_STARSHIP = await deployContract(
    new NFT_starship__factory(deployer).deploy(
      deployer.address,

      {
        nonce: deployerNonce++,
      }
    )
  );

  // DEPLOY OPERATIONS
  const SHOP = await deployContract(
    new Shop__factory(deployer).deploy(
      deployer.address,
      EX_POINTS.address,
      deployer.address,
      {
        nonce: deployerNonce++,
      }
    )
  );
  const MANAGER_CLAIM = await deployContract(
    new ManagerClaim__factory(deployer).deploy(deployer.address, {
      nonce: deployerNonce++,
    })
  );
  const PLAY_EXPLORE = await deployContract(
    new PlayExplore__factory(deployer).deploy(
      deployer.address,
      [NFT_TICKET.address],
      {
        nonce: deployerNonce++,
      }
    )
  );

  // Log deployed contract addresses
  console.log(
    "Addresses: \n",
    `EXPOINTS: ${EX_POINTS.address} \n`,
    `TOKEN_GEM: ${TOKEN_GEM.address}\n`,
    `NFT_ASSET: ${NFT_ASSET.address}\n`,
    `NFT_TICKET: ${NFT_TICKET.address}\n`,
    `NFT_PASS: ${NFT_PASS.address}\n`,
    `NFT_STARSHIP: ${NFT_STARSHIP.address}\n`,
    `SHOP: ${SHOP.address}\n`,
    `MANAGER_CLAIM: ${MANAGER_CLAIM.address}\n`,
    `PLAY_EXPLORE: ${PLAY_EXPLORE.address}\n`
  );

  // SETUP the whole process
  await waitForTx(
    NFT_ASSET.addAllowedContract(SHOP.address, { nonce: deployerNonce++ })
  );
  await waitForTx(
    NFT_TICKET.addAllowedContract(SHOP.address, { nonce: deployerNonce++ })
  );
  await waitForTx(
    NFT_PASS.addAllowedContract(SHOP.address, { nonce: deployerNonce++ })
  );
  await waitForTx(
    NFT_STARSHIP.addAllowedContract(SHOP.address, { nonce: deployerNonce++ })
  );

  // add manager control
  await waitForTx(
    NFT_ASSET.addAllowedContract(MANAGER_CLAIM.address, {
      nonce: deployerNonce++,
    })
  );
  await waitForTx(
    NFT_TICKET.addAllowedContract(MANAGER_CLAIM.address, {
      nonce: deployerNonce++,
    })
  );
  await waitForTx(
    NFT_PASS.addAllowedContract(MANAGER_CLAIM.address, {
      nonce: deployerNonce++,
    })
  );
  await waitForTx(
    NFT_STARSHIP.addAllowedContract(MANAGER_CLAIM.address, {
      nonce: deployerNonce++,
    })
  );

  console.log("\n\t-- MANAGER SETUP --");
  // 0
  await waitForTx(
    MANAGER_CLAIM.addContract(NFT_PASS.address, "PASS", "2", {
      nonce: deployerNonce++,
    })
  );

  // 1
  await waitForTx(
    MANAGER_CLAIM.addContract(NFT_TICKET.address, "TICKET", "2", {
      nonce: deployerNonce++,
    })
  );

  // 2
  await waitForTx(
    MANAGER_CLAIM.addContract(NFT_ASSET.address, "NFT_ASSET", "3", {
      nonce: deployerNonce++,
    })
  );

  // 3
  await waitForTx(
    MANAGER_CLAIM.addContract(NFT_ASSET.address, "NFT_ASSET", "3", {
      nonce: deployerNonce++,
    })
  );

  // 4
  await waitForTx(
    MANAGER_CLAIM.addContract(NFT_STARSHIP.address, "NFT_STARSHIP", "3", {
      nonce: deployerNonce++,
    })
  );

  // 5
  await waitForTx(
    MANAGER_CLAIM.addContract(EX_POINTS.address, "EXPOINTS", "1", {
      nonce: deployerNonce++,
    })
  );

  // 6
  await waitForTx(
    MANAGER_CLAIM.addContract(TOKEN_GEM.address, "TOKEN_GEM", "1", {
      nonce: deployerNonce++,
    })
  );

  console.log("\n\t-- SHOP SETUP --");

  // EX GEM payment token
  await waitForTx(
    SHOP.addPaymentToken(TOKEN_GEM.address, "EX GEM", {
      nonce: deployerNonce++,
    })
  );

  // pass 0
  await waitForTx(
    SHOP.addProduct(
      NFT_PASS.address,
      [BigNumber.from("10000000000000000000")],
      0,
      "pass",
      0,
      {
        nonce: deployerNonce++,
      }
    )
  );

  // ticket 1
  await waitForTx(
    SHOP.addProduct(
      NFT_TICKET.address,
      [BigNumber.from("1000000000000000000")],
      0,
      "ticket",
      0,
      {
        nonce: deployerNonce++,
      }
    )
  );

  // ship 2
  await waitForTx(
    SHOP.addProduct(
      NFT_STARSHIP.address,
      [BigNumber.from("25000000000000000000")],
      0,
      "ship",
      0,
      {
        nonce: deployerNonce++,
      }
    )
  );

  // asset 3
  await waitForTx(
    SHOP.addProduct(
      NFT_ASSET.address,
      [BigNumber.from("5000000000000000000")],
      0,
      "asset",
      0,
      {
        nonce: deployerNonce++,
      }
    )
  );

  // asset 4
  await waitForTx(
    SHOP.addProduct(
      NFT_ASSET.address,
      [BigNumber.from("5000000000000000000")],
      0,
      "asset",
      0,
      {
        nonce: deployerNonce++,
      }
    )
  );

  console.log("\n\t-- COMPLETED --");

  //   // Usage
  // await waitForTx(NFT_ASSET.connect(deployer).addAllowedContract(SHOP.address));
  // await waitForTx(NFT_TICKET.connect(deployer).addAllowedContract(SHOP.address));
  // await waitForTx(NFT_PASS.connect(deployer).addAllowedContract(SHOP.address));
  // await waitForTx(NFT_STARSHIP.connect(deployer).addAllowedContract(SHOP.address));

  // // add manager control
  // await waitForTx(NFT_ASSET.connect(deployer).addAllowedContract(MANAGER_CLAIM.address));
  // await waitForTx(NFT_TICKET.connect(deployer).addAllowedContract(MANAGER_CLAIM.address));
  // await waitForTx(NFT_PASS.connect(deployer).addAllowedContract(MANAGER_CLAIM.address));
  // await waitForTx(NFT_STARSHIP.connect(deployer).addAllowedContract(MANAGER_CLAIM.address));
  // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
