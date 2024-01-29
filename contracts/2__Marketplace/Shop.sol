// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniversalClaim {
  function mintToken(address to, uint256 amount) external; // respective to erc20

  function mintCollectible(address to) external; // respective to erc721

  function mintCollectibleId(
    address to,
    uint256 tokenId,
    uint256 amount
  ) external; // respective to erc1155
}

/// @title A shop for selling starex's asset
/// @author 0xdellwatson
/// @dev need to add auction and several todo later
contract Shop is Ownable {
  struct ContractInfo {
    address contractAddress;
    string contractName;
    uint256 tokenType; // 1 for ERC20, 2 for ERC721, 3 for ERC1155
    // bool isPaused;
  }

  struct PaymentToken {
    address contractAddress;
    string tokenName;
  }

  struct Product {
    address nftAddress;
    uint256[] prices;
    // PaymentToken[] paymentTokens;
    uint256 id_token;
    string category;
    uint256 points;
  }

  mapping(uint256 => ContractInfo) public listedContracts;
  mapping(uint256 => Product) public listedProducts;
  uint256 public productCount;
  uint256 public contractCount; // To keep track of the number of listed contracts
  address public pointsAddress;
  address public paymentDistributionAddress;
  uint256 public paymentDistributionPercentage = 10;
  PaymentToken[] public paymentTokens;

  event ProductListed(
    uint256 indexed productId,
    address indexed nftAddress,
    uint256[] prices,
    uint256 id_token,
    string category,
    uint256 points
  );
  event ProductRemoved(uint256 indexed productId);
  event PaymentDistributionAddressChanged(address indexed newAddress);
  event PaymentDistributionPercentageChanged(uint256 newPercentage);

  constructor(
    address initialOwner,
    address _pointContract,
    address _vendor
  ) Ownable(initialOwner) {
    // Initialize with the owner's address for points and payment distribution
    pointsAddress = _pointContract;
    paymentDistributionAddress = _vendor;
  }

  function addPaymentToken(address contractAddress, string memory tokenName)
    public
    onlyOwner
  {
    paymentTokens.push(PaymentToken(contractAddress, tokenName));
  }

  function getPaymentTokens() public view returns (PaymentToken[] memory) {
    return paymentTokens;
  }

  function setPointsAddress(address newPointsAddress) public onlyOwner {
    pointsAddress = newPointsAddress;
  }

  function setPaymentDistributionAddress(address newDistributionAddress)
    public
    onlyOwner
  {
    paymentDistributionAddress = newDistributionAddress;
  }

  function setPaymentDistributionPercentage(uint256 newPercentage)
    public
    onlyOwner
  {
    require(newPercentage <= 100, "Percentage should be between 0 and 100");
    paymentDistributionPercentage = newPercentage;
  }

  // Function for the owner to add a contract to the list
  function addContract(
    address contractAddress,
    string memory contractName,
    uint256 tokenType
  ) public onlyOwner {
    listedContracts[contractCount] = ContractInfo(
      contractAddress,
      contractName,
      tokenType
    );
    contractCount++;
  }

  //   // Function for the owner to remove a contract from the list
  // BUG: contract delete corrupt the data??
  //   function removeContract(uint256 index) public onlyOwner {
  //     require(index < contractCount, "Invalid index");
  //     delete listedContracts[index];

  //     // Shift the elements to fill the gap
  //     for (uint256 i = index; i < contractCount - 1; i++) {
  //       listedContracts[i] = listedContracts[i + 1];
  //     }
  //     contractCount--;
  //   }

  // Function to view the list of contracts available for claiming
  function getContractList() public view returns (ContractInfo[] memory) {
    ContractInfo[] memory contracts = new ContractInfo[](contractCount);
    for (uint256 i = 0; i < contractCount; i++) {
      contracts[i] = listedContracts[i];
    }
    return contracts;
  }

  //todo update multiple prices
  //update tags, and category level for sorting
  //
  function addProduct(
    address nftAddress, // change into contractAddress because erc20 items?
    uint256[] memory prices,
    uint256 id_token, // ignore if 721, this is for 1155
    string memory category,
    uint256 points
  ) public onlyOwner {
    // Create a new product
    Product memory newProduct = Product(
      nftAddress,
      prices,
      id_token,
      category,
      points
    );

    // Add the new product to the mapping
    listedProducts[productCount] = newProduct;

    // Increment the product count
    productCount++;
    emit ProductListed(
      productCount - 1,
      nftAddress,
      prices,
      id_token,
      category,
      points
    );
  }

  // function removeProduct(uint256 productId) public onlyOwner {
  //   require(productId < listedProducts.length, "Invalid product ID");
  //   delete listedProducts[productId];
  //   emit ProductRemoved(productId);
  // }

  //TODO: upgrade into multiple cart buy + coupon
  // redo with multiple PRICES
  function buyProduct(
    uint256 productId,
    uint256 paymentAmount,
    address paymentToken,
    uint256 quantity,
    uint256 tokenType //todo: remove this and use from contracts??
  ) public payable {
    // require(productId < listedProducts.length, "Invalid product ID");
    Product memory product = listedProducts[productId];

    require(product.prices.length > 0, "Product prices not set");

    // Find the matching PaymentToken
    bool paymentTokenFound = false;

    for (uint256 i = 0; i < paymentTokens.length; i++) {
      if (paymentTokens[i].contractAddress == paymentToken) {
        paymentTokenFound = true;
        break;
      }
    }
    require(paymentTokenFound, "Invalid payment token");

    // TODO: one more check for paymentAmount ===  product price * quantity or direct?

    if (product.prices[0] == 0) {
      // Ether payment
      require(msg.value >= paymentAmount, "Insufficient Ether payment");
      // Transfer Ether to the seller (shop owner)
      payable(owner()).transfer(paymentAmount);
    } else {
      // Handle ERC20 token transfer
      // Check allowance and balance for the selected payment token
      uint256 allowance = IERC20(paymentToken).allowance(
        msg.sender,
        address(this)
      );
      uint256 buyerBalance = IERC20(paymentToken).balanceOf(msg.sender);

      require(paymentAmount <= allowance, "Token allowance not sufficient");
      require(paymentAmount <= buyerBalance, "Token balance not sufficient");

      // Transfer tokens from the buyer to the contract
      require(
        IERC20(paymentToken).transferFrom(
          msg.sender,
          address(this),
          paymentAmount
        ),
        "Token transfer failed"
      );
    }

    // // Distribute payment
    // uint256 distributorPayment = (paymentAmount *
    //   paymentDistributionPercentage) / 100;

    // TODO: REUSE MANAGER CLAIM CONTRACT INSTEAD
    if (tokenType == 2) {
      // ERC721
      IUniversalClaim(product.nftAddress).mintCollectible(msg.sender);
    } else if (tokenType == 3) {
      // ERC1155
      IUniversalClaim(product.nftAddress).mintCollectibleId(
        msg.sender,
        product.id_token,
        quantity
      );
    }

    //send points later
  }
}
