// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Enumerable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17URIStorage.sol";
import "@klaytn/contracts/access/Ownable.sol";
//integrating with ticket nft
contract SeasonPASS is KIP17, KIP17Enumerable, KIP17URIStorage, Ownable {
  uint256 private _nextTokenId;

  // Mapping to store the expiration date for each NFT
  mapping(uint256 => uint256) public expirationDates;

  // State variable to control the length of the expiration (in seconds)
  uint256 public expirationLength;

  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

    constructor() KIP17("TICKET", "TICKET") 
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(KIP17, KIP17Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(KIP17, KIP17URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(KIP17, KIP17URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(KIP17, KIP17Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
