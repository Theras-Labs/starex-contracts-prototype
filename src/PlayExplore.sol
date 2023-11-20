// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PlayExplore is Ownable {
    // Mapping to keep track of accepted NFT addresses
    mapping(address => bool) public acceptedNFTs;

    // Counter for total collected/locked NFTs
    uint256 public totalLockedNFTs;

    // Event to log when an NFT is locked
    event NFTLocked(address indexed owner, address indexed nftContract, uint256 tokenId);

    // Constructor to initialize the contract with accepted NFT addresses
    constructor(address initialOwner, address[] memory initialAcceptedNFTs)
     Ownable(initialOwner) {
        for (uint256 i = 0; i < initialAcceptedNFTs.length; i++) {
            acceptedNFTs[initialAcceptedNFTs[i]] = true;
        }
    }

    // Function to add an NFT contract to the list of accepted NFTs (only owner can do this)
    function addAcceptedNFT(address nftContract) external onlyOwner {
        acceptedNFTs[nftContract] = true;
    }

    // Function to remove an NFT contract from the list of accepted NFTs (only owner can do this)
    function removeAcceptedNFT(address nftContract) external onlyOwner {
        acceptedNFTs[nftContract] = false;
    }

    // Function to lock an NFT in this contract
    function lockNFT(address nftContract, uint256 tokenId) external {
        require(acceptedNFTs[nftContract], "NFT not accepted");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");

        // Transfer the NFT to this contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Update the total locked NFT count
        totalLockedNFTs++;

        // Emit an event
        emit NFTLocked(msg.sender, nftContract, tokenId);
    }

    // Function to get the total number of locked NFTs
    function getTotalLockedNFTs() external view returns (uint256) {
        return totalLockedNFTs;
    }
}
