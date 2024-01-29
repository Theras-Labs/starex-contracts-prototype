# Game Contracts README

## Overview

This repository contains the Solidity smart contracts that govern various aspects of our blockchain-based game. These contracts facilitate the creation, management, and interaction with in-game assets, transactions, and special features. Below is an overview of the key contracts and their purposes.
\*Due to security concern, the submission of the contracts has limited features, and not the final code

### Smart Contracts

1. **GEMTOKEN or fUSD**

   - Address: `` (erc20)
   - Description: Manages the game's native token (GEMTOKEN or fake USD) following the erc-20 standard.

2. **EXPOINTS**

   - Address: `` (erc-20)
   - Description: Handles experience points (EXPOINTS) based on the erc20 standard.

3. **NFT ASSETS**

   - Address: `` (ERC-1155)
   - Description: Manages non-fungible assets (NFTASSET) with unique identifiers following the ERC-1155 standard. This will be full available materials scattered inside the game as well as abilities and items as NFT.

4. **NFT STARSHIP**

   - Address: `` (ERC-721)
   - Description: Manages non-fungible starships (NFTSTARSHIP) following the ERC-721 standard.
   - Updated: starship now is 721 because each ship even with the same model could have different traits and different chain comes from, as well as earning experience which would grow in value.

5. **NFT PASS**

   - Address: `` (ERC-1155)
   - Description: Manages non-fungible passes (NFTPASS) following the ERC-1155.
   - Updated: NFT Pass is now 1155, will be tradeable after activation time expired. So instead working as subscription, it will work just like other Game-PASS that will end in the end of season no matter what time user bought/mint it.

6. **NFT TICKET**

   - Address: `` (ERC-721)
   - Description: Manages non-fungible tickets (NFTTICKET) following the ERC-721 standard.

7. **ClAIM OPERATOR**

   - Address: ``
   - Description: Handles backend data management and securely mints NFTs to respective contracts. Allows users to claim NFTs through frontend using EIP712 signatures.

8. **EXPLOREPLAY**

   - Address: ``
   - Description: Handles the ticket-NFTs when entering other dimensions and return the droprate in-game and after game

9. **SHOP**

   - Address: ``
   - Description: Manages in-game shop logic, requiring correct token payments for products listed in the shop storage.

10. **SWAP OPERATOR**

- Address: ``
- Description: SWAP token standard to the STAREX universal cross-chain token from backend using eip-712
  // currently not deployed due to sync with backend and progress only intended to show for Injective network and not cross-chain demo

## Manager Claim

The Manager Claim contract is designed for managing backend data. When players acquire NFTs during gameplay, the data is recorded in the backend. The backend provides a signature for users to claim their pending NFTs through the frontend using EIP712. The Manager Claim contract securely mints these NFTs to the respective contracts.

## Shop Contract

Similar to the Manager Claim, the Shop contract manages backend data but requires correct token payments for products listed in the shop storage. Users can purchase in-game items by interacting with this contract.

## EXPEDITION-Play Contract

Users stake/lock their ticket-NFTs when attempting to enter other dimensions within the game. This contract governs the logic for this process.

## Season Pass

The Season Pass contract is similar to a subscription, providing a time-limited soulbond token. It operates similarly to the points-token (KIP-7), which can be earned through gameplay or purchased from the store. These points can later be used to acquire items in the shop.

## Future Integrations

Additional contracts will be introduced as the game progresses into beta around January 2024. Stay tuned for updates on new features and functionalities.

For any inquiries or issues, please contact our development team.

![Game Contracts](./pics.png)
