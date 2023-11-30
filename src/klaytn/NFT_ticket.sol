// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Enumerable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17URIStorage.sol";
import "@klaytn/contracts/access/Ownable.sol";


contract TICKET is KIP17, KIP17Enumerable, KIP17URIStorage, Ownable {
    uint256 private _nextTokenId;

    // Mapping to store rarity tiers for each tokenId
    mapping(uint256 => uint256) public rarityTiers;

    // Mapping to store the price for each tokenId
    mapping(uint256 => uint256) public tokenPrices;

    // Mapping to store allowed contracts for minting
    mapping(address => bool) public allowedContracts;

    constructor(address initialOwner)
        KIP17("TICKET", "TICKET")
        Ownable(initialOwner)
    {}

    // Modifier to allow only Shop contracts to call mintFromShopContract
    modifier onlyShop() {
        require(allowedContracts[msg.sender], "Only allowed Shop contract can call this function");
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://metadata/";
    }

    // Function for the owner to add an allowed contract
    function addAllowedContract(address contractAddress) public onlyOwner {
        allowedContracts[contractAddress] = true;
    }

    // Function for the owner to remove an allowed contract
    function removeAllowedContract(address contractAddress) public onlyOwner {
        allowedContracts[contractAddress] = false;
    }

    // Internal function to safely mint a token
    function internalSafeMint(address to, string memory uri
    //  uint256 tier
     ) internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        // rarityTiers[tokenId] = tier;
    }

    // Function to mint tokens from the Shop contract
    function mintCollectible(
        address to
        // string memory uri
        // uint256 tier
    ) public onlyShop {
        internalSafeMint(to, "todo-uri");
        // internalSafeMint(to, uri, tier);
    }

    // The following functions are overrides required by Solidity.
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
