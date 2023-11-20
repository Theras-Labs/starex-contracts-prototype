// ContractListing.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ContractListing {
  struct ContractInfo {
    address contractAddress;
    string contractName;
  }

  function addContract(
    mapping(uint256 => ContractInfo) storage contracts,
    address contractAddress,
    string memory contractName
  ) internal {
    uint256 index = contracts.length;
    contracts[index] = ContractInfo(contractAddress, contractName);
  }

  function removeContract(
    mapping(uint256 => ContractInfo) storage contracts,
    uint256 index
  ) internal {
    require(index < contracts.length, "Invalid contract index");
    delete contracts[index];

    // Shift the elements to fill the gap
    for (uint256 i = index; i < contracts.length - 1; i++) {
      contracts[i] = contracts[i + 1];
    }
    contracts.pop();
  }

  function getContractList(mapping(uint256 => ContractInfo) storage contracts)
    internal
    view
    returns (ContractInfo[] memory)
  {
    ContractInfo[] memory contractList = new ContractInfo[](contracts.length);
    for (uint256 i = 0; i < contracts.length; i++) {
      contractList[i] = contracts[i];
    }
    return contractList;
  }
}
