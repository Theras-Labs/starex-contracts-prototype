// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT_starship is
  ERC721,
  ERC721Enumerable,
  ERC721URIStorage,
  ERC721Burnable,
  Ownable
{
  uint256 private _nextTokenId;
  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

  constructor(address initialOwner)
    ERC721("Star Ship", "SHIP")
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

  // Function to add an allowed contract
  function addAllowedContract(address contractAddress) public onlyOwner {
    allowedContracts[contractAddress] = true;
  }

  // Function to remove an allowed contract
  function removeAllowedContract(address contractAddress) public onlyOwner {
    allowedContracts[contractAddress] = false;
  }

  function mintCollectible(address to) public onlyShop {
    uint256 tokenId = _nextTokenId++;
    _safeMint(to, tokenId);
    // setup random rarity here, and url types
    _setTokenURI(tokenId, "URI");
  }

  function _baseURI() internal pure override returns (string memory) {
    return "https://metadata/star-ship";
  }

  // The following functions are overrides required by Solidity.

  function _update(
    address to,
    uint256 tokenId,
    address auth
  ) internal override(ERC721, ERC721Enumerable) returns (address) {
    return super._update(to, tokenId, auth);
  }

  function _increaseBalance(address account, uint128 value)
    internal
    override(ERC721, ERC721Enumerable)
  {
    super._increaseBalance(account, value);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable, ERC721URIStorage)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
