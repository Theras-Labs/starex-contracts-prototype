import { BigNumber, Contract, Signer } from "ethers";
import { ethers } from "hardhat";

async function main() {
  // Get the deployer's signer address
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer address: ${deployer.address}`);

  // Fetch the current gas price from the network
  const gasPrice = await ethers.provider.getGasPrice();
  console.log(
    `Current gas price: ${gasPrice.toString()} wei`,
    gasPrice.mul(40)
  );

  // Contract Factories
  const ExPoints__factory = await ethers.getContractFactory("ExPoints");
  const tokenGEMFactory = await ethers.getContractFactory("EXGEM");
  const nftAssetFactory = await ethers.getContractFactory("AssetContract");
  const nftTicketFactory = await ethers.getContractFactory("TICKET");
  const nftPassFactory = await ethers.getContractFactory("SeasonPASS");
  const nftStarShipFactory = await ethers.getContractFactory("NFT_starship");
  const Shop__factory = await ethers.getContractFactory("Shop");
  const ManagerClaim__factory = await ethers.getContractFactory("ManagerClaim");
  const PlayExplore__factory = await ethers.getContractFactory("PlayExplore");

  // Deploy contracts with dynamically fetched gas price
  const EXPOINTS = await ExPoints__factory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });
  const TOKEN_GEM = await tokenGEMFactory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });
  const NFT_ASSET = await nftAssetFactory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });
  const NFT_TICKET = await nftTicketFactory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });
  const NFT_PASS = await nftPassFactory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });
  const NFT_STARSHIP = await nftStarShipFactory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });

  // Deploy Shop contract with dependencies
  const SHOP = await Shop__factory.deploy(
    deployer.address,
    EXPOINTS.address,
    deployer.address,
    { gasPrice: gasPrice.mul(40) } // You can adjust the multiplier as needed
  );

  const MANAGER_CLAIM = await ManagerClaim__factory.deploy(deployer.address, {
    gasPrice: gasPrice.mul(40), // You can adjust the multiplier as needed
  });

  // Deploy PlayExplore contract with dependencies
  const PLAY_EXPLORE = await PlayExplore__factory.deploy(
    deployer.address,
    [NFT_TICKET.address],
    { gasPrice: gasPrice.mul(40) }
  ); // You can adjust the multiplier as needed

  // Log deployed contract addresses
  console.log(
    "Addresses: \n",
    `EXPOINTS: ${EXPOINTS.address} \n`,
    `TOKEN_GEM: ${TOKEN_GEM.address}\n`,
    `NFT_ASSET: ${NFT_ASSET.address}\n`,
    `NFT_TICKET: ${NFT_TICKET.address}\n`,
    `NFT_PASS: ${NFT_PASS.address}\n`,
    `NFT_STARSHIP: ${NFT_STARSHIP.address}\n`,
    `SHOP: ${SHOP.address}\n`,
    `MANAGER_CLAIM: ${MANAGER_CLAIM.address}\n`,
    `PLAY_EXPLORE: ${PLAY_EXPLORE.address}\n`
  );

  // FINISSSHHH DEPLOY

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

  console.log("MANAGER SETUP NOW");
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

  console.log("SHOP SETUP NOW");

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
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
