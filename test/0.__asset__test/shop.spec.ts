import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import {
  BTC_VALUE,
  DECIMALS,
  WETH_VALUE,
  convertToUSD,
  convertUnits,
} from "../../tasks/helpers/utils";
// import {
//   ExPoints__factory,
//   SwapContract__factory,
// } from "../../typechain-types";
require("mocha-reporter").hook();

async function deployFixture() {
  // Contracts are deployed using the first signer/account by default
  const [deployer, vendor, alice, bob, charlie] = await ethers.getSigners();

  // FACTORIES
  const ExPoints__factory = await ethers.getContractFactory("ExPoints");
  const tokenGEMFactory = await ethers.getContractFactory("EXGEM");
  const nftAssetFactory = await ethers.getContractFactory("AssetContract");
  const nftTicketFactory = await ethers.getContractFactory("TICKET");
  const nftPassFactory = await ethers.getContractFactory("SeasonPASS");
  const nftStarShipFactory = await ethers.getContractFactory("NFT_starship");
  const Shop__factory = await ethers.getContractFactory("Shop");
  const ManagerClaim__factory = await ethers.getContractFactory("ManagerClaim");
  const PlayExplore__factory = await ethers.getContractFactory("PlayExplore");

  // DEPLOY
  const EXPOINTS = await ExPoints__factory.deploy(deployer.address);
  const TOKEN_GEM = await tokenGEMFactory.deploy(deployer.address);
  const NFT_ASSET = await nftAssetFactory.deploy(deployer.address);
  const NFT_TICKET = await nftTicketFactory.deploy(deployer.address);
  const NFT_PASS = await nftPassFactory.deploy(deployer.address);
  const NFT_STARSHIP = await nftStarShipFactory.deploy(deployer.address);
  const SHOP = await Shop__factory.deploy(
    deployer.address,
    EXPOINTS.address,
    vendor.address
  );
  const MANAGER_CLAIM = await ManagerClaim__factory.deploy(deployer.address);
  const PLAY_EXPLORE = await PlayExplore__factory.deploy(deployer.address, [
    NFT_TICKET.address,
  ]);

  console.log(
    "Addresses:",
    `EXPOINTS: ${EXPOINTS.address}`,
    `TOKEN_GEM: ${TOKEN_GEM.address}`,
    `NFT_ASSET: ${NFT_ASSET.address}`,
    `NFT_TICKET: ${NFT_TICKET.address}`,
    `NFT_PASS: ${NFT_PASS.address}`,
    `NFT_STARSHIP: ${NFT_STARSHIP.address}`,
    `SHOP: ${SHOP.address}`,
    `MANAGER_CLAIM: ${MANAGER_CLAIM.address}`,
    `PLAY_EXPLORE: ${PLAY_EXPLORE.address}`
  );

  // add shop/ store to modifier
  await NFT_ASSET.connect(deployer).addAllowedContract(SHOP.address);
  await NFT_TICKET.connect(deployer).addAllowedContract(SHOP.address);
  await NFT_PASS.connect(deployer).addAllowedContract(SHOP.address);
  await NFT_STARSHIP.connect(deployer).addAllowedContract(SHOP.address);
  // add manager control
  await NFT_ASSET.connect(deployer).addAllowedContract(MANAGER_CLAIM.address);
  await NFT_TICKET.connect(deployer).addAllowedContract(MANAGER_CLAIM.address);
  await NFT_PASS.connect(deployer).addAllowedContract(MANAGER_CLAIM.address);
  await NFT_STARSHIP.connect(deployer).addAllowedContract(
    MANAGER_CLAIM.address
  );
  // manager setup
  //0
  await MANAGER_CLAIM.connect(deployer).addContract(
    NFT_PASS.address,
    "pass",
    "2"
  );
  //1
  await MANAGER_CLAIM.connect(deployer).addContract(
    NFT_TICKET.address,
    "TICKET",
    "2"
  );
  //2
  await MANAGER_CLAIM.connect(deployer).addContract(
    NFT_ASSET.address,
    "NFT_ASSET",
    "3"
  );
  //3
  await MANAGER_CLAIM.connect(deployer).addContract(
    NFT_ASSET.address,
    "NFT_ASSET",
    "3"
  );
  //4
  await MANAGER_CLAIM.connect(deployer).addContract(
    NFT_STARSHIP.address,
    "NFT_STARSHIP",
    "3"
  );
  //5
  await MANAGER_CLAIM.connect(deployer).addContract(
    EXPOINTS.address,
    "EXPOINTS",
    "1"
  );
  //6
  await MANAGER_CLAIM.connect(deployer).addContract(
    TOKEN_GEM.address,
    "TOKEN_GEM",
    "1"
  );

  //   address nftAddress, // change into contractAddress because erc20 items?
  //   uint256[] memory prices,
  //   uint256 id_token, // ignore if 721, this is for 1155
  //   string memory category,
  //   uint256 points
  // SHOP SETUP;
  // pass 0
  await SHOP.connect(deployer).addPaymentToken(TOKEN_GEM.address, "EX GEM");
  await SHOP.connect(deployer).addProduct(
    NFT_PASS.address,
    [BigNumber.from("10000000000000000000")],
    0,
    "pass",
    0
  );

  // ticket 1
  await SHOP.connect(deployer).addProduct(
    NFT_TICKET.address,
    [BigNumber.from("1000000000000000000")],
    0,
    "ticket",
    0
  );

  // ship 2
  await SHOP.connect(deployer).addProduct(
    NFT_STARSHIP.address,
    [BigNumber.from("25000000000000000000")],
    0,
    "ship",
    0
  );

  // asset 3
  await SHOP.connect(deployer).addProduct(
    NFT_ASSET.address,
    [BigNumber.from("5000000000000000000")],
    0,
    "asset",
    0
  );

  await SHOP.connect(deployer).addProduct(
    NFT_ASSET.address,
    [BigNumber.from("5000000000000000000")],
    0,
    "asset",
    0
  );

  return {
    EXPOINTS,
    TOKEN_GEM,
    NFT_ASSET,
    NFT_TICKET,
    NFT_PASS,
    NFT_STARSHIP,
    SHOP,
    MANAGER_CLAIM,
    PLAY_EXPLORE,
    vendor,
    bob,
    alice,
    charlie,
  };
}

describe("Shop Listing  ", function () {
  let alice: Signer;
  let charlie: Signer;
  let bob: Signer;
  let vendor: Signer;

  let EXPOINTS: Contract;
  let TOKEN_GEM: Contract;
  let NFT_ASSET: Contract;
  let NFT_TICKET: Contract;
  let NFT_PASS: Contract;
  let NFT_STARSHIP: Contract;
  let SHOP: Contract;
  let MANAGER_CLAIM: Contract;
  let PLAY_EXPLORE: Contract;

  before(async function () {
    // Initialize the contract and other variables once before all tests
    ({
      EXPOINTS,
      TOKEN_GEM,
      NFT_ASSET,
      NFT_TICKET,
      NFT_PASS,
      NFT_STARSHIP,
      SHOP,
      MANAGER_CLAIM,
      PLAY_EXPLORE,
      vendor,
      alice,
      bob,
      charlie,
    } = await loadFixture(deployFixture));
  });

  //   uint256[] memory contractIndices,
  //   uint256[] memory amounts,
  //   uint256[] memory ids
  it("Should be able to claim", async function () {
    //claim gem
    await MANAGER_CLAIM.connect(alice).claim(
      [BigNumber.from("6")],
      [BigNumber.from("5000")],
      [BigNumber.from("0")]
    );
    const aliceBalance = await TOKEN_GEM.balanceOf(alice.address);
    console.log(aliceBalance, "aliceBalance");

    //check starship gem
    const aliceBalanceSTARSHIP = await NFT_STARSHIP.balanceOf(alice.address, 0);
    console.log(aliceBalanceSTARSHIP, "aliceBalanceSTARSHIP");

    await TOKEN_GEM.connect(alice).approve(
      SHOP.address,
      BigNumber.from("250000000000000000000")
    );

    // uint256 productId,
    // uint256 paymentAmount,
    // address paymentToken,
    // uint256 quantity,
    // uint256 tokenType //
    await SHOP.connect(alice).buyProduct(
      2,
      BigNumber.from("25000000000000000000"),
      TOKEN_GEM.address,
      1,
      3
    );
    // await SHOP.connect(alice).buyProduct

    const aliceBalance1 = await TOKEN_GEM.balanceOf(alice.address);
    console.log(aliceBalance1, "aliceBalance1");

    //check starship gem
    const aliceBalanceSTARSHIP1 = await NFT_STARSHIP.balanceOf(
      alice.address,
      0
    );
    console.log(aliceBalanceSTARSHIP1, "aliceBalanceSTARSHIP1");
  });
});
