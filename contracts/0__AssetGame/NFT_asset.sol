// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Asset starex contract
/// @author 0xdellwatson
/// @notice not including the abilities?
contract AssetContract is ERC1155, Ownable {
  // Mapping to store the total supply for each token ID
  mapping(uint256 => uint256) public tokenTotalSupply;

  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

  constructor(address initialOwner)
    ERC1155("https://metadata")
    Ownable(initialOwner)
  {}

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
