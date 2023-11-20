// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//integrating with ticket nft
contract SeasonPASS is ERC721, ERC721URIStorage, Ownable {
  uint256 private _nextTokenId;

  // Mapping to store the expiration date for each NFT
  mapping(uint256 => uint256) public expirationDates;

  // State variable to control the length of the expiration (in seconds)
  uint256 public expirationLength;

  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

  constructor(address initialOwner)
    ERC721("Season PASS", "PASS")
    Ownable(initialOwner)
  {
    // Initialize the expiration length (e.g., 365 days)
    // expirationLength = 30 days;
    expirationLength = 300; // 5mins
    // expirationLength = 1 hours;
  }

  // Modifier to allow only Shop contracts to call mintFromContract
  modifier onlyShop() {
    require(
      allowedContracts[msg.sender],
      "Only allowed Shop contract can call this function"
    );
    _;
  }

  function _baseURI() internal pure override returns (string memory) {
    return "https://metadata/";
  }


  function mintCollectible(address to) external onlyShop {
    uint256 tokenId = _nextTokenId++;
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, "todo-uri");

    // Set the expiration date for the minted NFT
    expirationDates[tokenId] = block.timestamp + expirationLength;
  }

// Function to check if an NFT is expired
function isExpired(uint256 tokenId) public view returns (bool) {
    require(ownerOf(tokenId) != address(0), "Token does not exist");
    return block.timestamp > expirationDates[tokenId];
}


    // Function for the owner to add an allowed contract
  function addAllowedContract(address contractAddress) public onlyOwner {
      allowedContracts[contractAddress] = true;
  }

  // Function for the owner to remove an allowed contract
  function removeAllowedContract(address contractAddress) public onlyOwner {
      allowedContracts[contractAddress] = false;
  }
  // Function to read the expiration date of an NFT
  function getExpirationDate(uint256 tokenId) public view returns (uint256) {
    return expirationDates[tokenId];
  }

  // Function for the owner to change the expiration length
  function setExpirationLength(uint256 newExpirationLength) public onlyOwner {
    expirationLength = newExpirationLength;
  }

  // The following functions are overrides required by Solidity.

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
    override(ERC721, ERC721URIStorage)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
