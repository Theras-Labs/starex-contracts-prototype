// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@klaytn/contracts/KIP/token/KIP37/KIP37.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/KIP/token/KIP37/extensions/KIP37Supply.sol";
import "@klaytn/contracts/KIP/interface/IKIP7.sol";


contract AssetContract is KIP37, Ownable, KIP37Supply {
  // Mapping to store the total supply for each token ID
  mapping(uint256 => uint256) public tokenTotalSupply;

  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

  constructor() KIP37("https://assetmetadata") {}
  // Modifier to allow only Shop contracts to call mintFromContract
  modifier onlyShop() {
    require(
      allowedContracts[msg.sender],
      "Only allowed Shop contract can call this function"
    );
    _;
  }

  // Function to set the total supply for a specific token ID
  function setTokenTotalSupply(uint256 tokenId, uint256 totalSupply)
    public
    onlyOwner
  {
    require(totalSupply > 0, "Total supply must be greater than 0");
    tokenTotalSupply[tokenId] = totalSupply;
  }

  // Function to add an allowed contract
  function addAllowedContract(address contractAddress) public onlyOwner {
    allowedContracts[contractAddress] = true;
  }

  // Function to remove an allowed contract
  function removeAllowedContract(address contractAddress) public onlyOwner {
    allowedContracts[contractAddress] = false;
  }


      function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

  
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
  // Function to mint tokens from another contract
  function mintCollectibleId(
    address to,
    uint256 tokenId,
    uint256 amount
  ) public onlyShop {
    require(tokenTotalSupply[tokenId] >= amount, "Exceeds token total supply");
    _mint(to, tokenId, amount, "");

    // there's asset not depends on supply, todo: update fn ssetup of tokenid
    tokenTotalSupply[tokenId] -= amount;
  }

  // Function to get the total supply for a specific token ID
  function getTokenTotalSupply(uint256 tokenId) public view returns (uint256) {
    return tokenTotalSupply[tokenId];
  }


}
