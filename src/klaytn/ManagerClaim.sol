// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniversalClaim {
  function mintToken(address to, uint256 amount) external; // respective to erc20

  function mintCollectible(address to) external; // respective to erc721

  function mintCollectibleId(
    address to,
    uint256 tokenId,
    uint256 amount
  ) external; // respective to erc1155
}

contract ManagerClaim is Ownable {
  struct ContractInfo {
    address contractAddress;
    string contractName;
    uint256 tokenType; // 1 for ERC20, 2 for ERC721, 3 for ERC1155
    // bool isPaused;
  }

  // Mapping to store the list of contracts available for claiming
  mapping(uint256 => ContractInfo) public listedContracts;

  uint256 public contractCount; // To keep track of the number of listed contracts

  constructor(address initialOwner) Ownable(initialOwner) {}

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

  // Function for the owner to remove a contract from the list
  function removeContract(uint256 index) public onlyOwner {
    require(index < contractCount, "Invalid index");
    delete listedContracts[index];

    // Shift the elements to fill the gap
    for (uint256 i = index; i < contractCount - 1; i++) {
      listedContracts[i] = listedContracts[i + 1];
    }
    contractCount--;
  }

  // Function to view the list of contracts available for claiming
  function getContractList() public view returns (ContractInfo[] memory) {
    ContractInfo[] memory contracts = new ContractInfo[](contractCount);
    for (uint256 i = 0; i < contractCount; i++) {
      contracts[i] = listedContracts[i];
    }
    return contracts;
  }

  function claim(
    uint256[] memory contractIndices,
    uint256[] memory amounts,
    uint256[] memory ids
    // bytes calldata signature    // use signature from backend
  ) public {
    require(
      contractIndices.length == amounts.length,
      "Input arrays must have the same length"
    );
    require(
      contractIndices.length == ids.length,
      "Input arrays must have the same length"
    );

    for (uint256 i = 0; i < contractIndices.length; i++) {
      require(contractIndices[i] < contractCount, "Invalid contract index");
      uint256 tokenType = listedContracts[contractIndices[i]].tokenType;

      if (tokenType == 1) {
        // ERC20
        IUniversalClaim(listedContracts[contractIndices[i]].contractAddress)
          .mintToken(msg.sender, amounts[i]);
      } else if (tokenType == 2) {
        // ERC721
        IUniversalClaim(listedContracts[contractIndices[i]].contractAddress)
          .mintCollectible(msg.sender);
      } else if (tokenType == 3) {
        // ERC1155
        uint256 tokenId = ids[i];
        IUniversalClaim(listedContracts[contractIndices[i]].contractAddress)
          .mintCollectibleId(msg.sender, tokenId, amounts[i]);
      }
    }
  }
}
