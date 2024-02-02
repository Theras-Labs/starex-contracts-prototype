# Game Contracts README

\*We are going live on april 2024

## Overview

This repository contains the Solidity smart contracts that govern various aspects of our blockchain-based game. These contracts facilitate the creation, management, and interaction with in-game assets, transactions, and special features. Below is an overview of the key contracts and their purposes.
\*Due to security concern, the submission of the contracts has limited features, and intended for early architecture, and not the final code which is using upgradeable contract

### 3 Mins Gameplay explained:

[![Starknet Update](https://img.youtube.com/vi/pi8XSNQL1fU/0.jpg)](https://www.youtube.com/watch?v=pi8XSNQL1fU)

*PITCH DECK and WHITEPAPER on pdfs folder


## Project Objectives:
STAR-EX, (EXPLORE, EXPEDITION) a groundbreaking CROSS-CHAIN web3 game that combines the thrill of exploration with the excitement of an incremental speed challenge.
his innovative concept encourages NETWORK COLLABORATION, where minority networks stand to gain exposure through in-game interactions and seasonal events. The dynamic in-game economy will be influenced by factors specific to each network, affecting asset values and drop rates. Stay tuned for more exciting details as we navigate the challenges of the hackathon and bring this cosmic adventure to life.

For Solo Exploration, players take control of a spaceship on an expedition through space, aptly named "ex" for exploration. Much like the classic Temple Run but now in 360 space with more fun abilities, the game dynamically increases in speed, presenting players with ever-growing challenges to survive.

In this interstellar adventure, players must navigate their spaceship through a cosmic obstacle course, avoiding rocks, monsters, and powerful boss encounters. The longer they last, the faster and more challenging the game becomes. Survival is key, but there's a catch—limited supplies of abilities and energy are essential for prolonged gameplay.  Players can discover unique items scattered throughout the in-game space. These items, represented as NFTs (Non-Fungible Tokens), not only grant special abilities but can also be traded in a marketplace, allowing players to turn their in-game achievements into real-world profit. Crafting items is crucial for obtaining the energy needed to activate powerful abilities, providing an additional layer of strategy. The scarcity of these resources adds depth to the gameplay, requiring players to make strategic decisions about when to use their items and abilities.

As the game progresses, Star-Ex evolves beyond its action roots. Players can choose to stake their spaceships as playing the MISSION and rewarding stake, transforming the experience into an idle game. This integration of action and idle gaming mechanics, combined with the NFT marketplace, creates a unique and sustainable gaming ecosystem. This game is actually not just action-arcade but my goal to make it into "Action-Idle RPG" as each spaceship has their own abilities, and some dimension location will be some weakness and strength depending for each spaceship, while it also provide stats that will carry within each NFTs.


## Technical framework:
- for Game we are utilising Threejs engine that capable to perform in high quality with WEBGPU compatibility.

### Smart Contracts

1. **GEMTOKEN or fUSD**

   - Address: `0xbe0833eB8f4Ff9BD5aEAFc2ee61925a227D58ABA` (erc20)
   - Description: Manages the game's native token (GEMTOKEN or fake USD or any partner erc20 within the network) following the erc-20 standard.

2. **EXPOINTS**

   - Address: `0xE39C0AAA925337a5499A2cCe0D906cc38B5CEA54` (erc-20)
   - Description: Handles experience points (EXPOINTS) based on the erc20 standard.

3. **NFT ASSETS**

   - Address: `0xC8E633D1Da2b23A12458682cB0d065A4452b6030` (ERC-1155)
   - Description: Manages non-fungible assets (NFTASSET) with unique identifiers following the ERC-1155 standard. This will be full available materials scattered inside the game as well as abilities and items as NFT.
   - update, new metadata consists of 200+ materials draft with 30 early abilities and items

4. **NFT STARSHIP**

   - Address: `0xa921a43516A0c85504d61bd3BD8bcE354a7bBEf1` (ERC-721)
   - Description: Manages non-fungible starships (NFTSTARSHIP) following the ERC-721 standard.
   - Updated: starship now is 721 because each ship even with the same model could have different traits and different chain comes from, as well as earning experience which would grow in value.

5. **NFT PASS**

   - Address: `0x9EcB83f041a8A3b76bcd9DafC078812047535ABc` (ERC-1155)
   - Description: Manages non-fungible passes (NFTPASS) following the ERC-1155.
   - Updated: NFT Pass is now 1155, will be tradeable after activation time expired. So instead working as subscription, it will work just like other Game-PASS that will end in the end of season no matter what time user bought/mint it.

6. **NFT TICKET**

   - Address: `0x5b6288be71623E408D61D0417A51572d7CBC10e2` (ERC-721)
   - Description: Manages non-fungible tickets (NFTTICKET) following the ERC-721 standard.

7. **ClAIM OPERATOR**

   - Address: `0x5c347CE1CA5606d992Fb31AB529C8A3d55a6E2d4`
   - Description: Handles backend data management and securely mints NFTs to respective contracts. Allows users to claim NFTs through frontend using EIP712 signatures.

8. **EXPLOREPLAY**

   - Address: `0x283C4Cc50D0209dA029b9a599EB28C80B3957B34`
   - Description: Handles the ticket-NFTs when entering other dimensions and return the droprate in-game and after game

9. **SHOP**

   - Address: `0xed3f3e6eBf67cf360C5EF3f650e0E69CC3a70CAb`
   - Description: Manages in-game shop logic, requiring correct token payments for products listed in the shop storage. This eventually will use eip-712 too for dynamic price and easier setup while not losing the security from offchain

10. **SWAP OPERATOR**

- Address: ``
- Description: SWAP token standard to the STAREX universal cross-chain token from backend using eip-712
  // currently not deployed due to sync with backend and progress only intended to show for Injective network and not cross-chain demo

11. **CRAFT OPERATOR** TBD

## Manager Claim

The Manager Claim contract is designed for managing backend data. When players acquire NFTs during gameplay, the data is recorded in the backend. The backend provides a signature for users to claim their pending NFTs through the frontend using EIP712. The Manager Claim contract securely mints these NFTs to the respective contracts.

## Shop Contract

Similar to the Manager Claim, the Shop contract manages backend data but requires correct token payments for products listed in the shop storage. Users can purchase in-game items by interacting with this contract.

## EXPEDITION-Play Contract

Users stake/lock their ticket-NFTs when attempting to enter other dimensions within the game. This contract governs the logic for this process.

## Season Pass

The Season Pass contract is similar to any SEASON PASS from mobile game, providing a time-limited soulbond token. It operates with the points-token (ERC-20) too, which can be earned through gameplay or purchased from the store. These points can later be used to acquire items in the shop.

## Future Integrations

Additional contracts will be introduced later. Stay tuned for updates on new features and functionalities.

For any inquiries or issues, please contact our development team.

![Game Contracts](./pics.png)


## Team expertise:
Current team:

**1. Dale (me):**
I play a pivotal role in the project, seamlessly blending technical expertise with strategic vision, designing the game model, envisioning innovative gameplay experiences. 

Taking a lead role in architecting the business model, leveraging my strategic thinking to ensure the project's long-term success. My responsibilities span the entire development lifecycle, from coding and infrastructure to envisioning the business model and engaging with the community.
Role: 
- Unicorn Developer (FE,BE, Mobile, Contract)
- Game and Business Designer
- Docs, Community, and Publication

In the future when funded ofc i want to release some of them and focused on taking Lead. 

previously I work as fullstack developer for 6years exp, the last team i joined was [0xpragma](0xpragma.com/network) a blockchain focused team that been working with [PlanetIX](ix.foundation) for 2 years that once was a no.1 polygon blockchain. I contribute in their DeFi and Frontend mostly while also contributed in several web3 projects in contract and fullstack development: 
1. Kindeck that become Alcacor ( a social NFT project )
2. Midas that become IONIC (DeFi)
3. SocialFi

- [github](https://github.com/dellwatson) - [twitter](https://twitter.com/dev_dellwatson) - [playstore](https://play.google.com/store/apps/dev?id=5858814158930016257) - [appstore](https://apps.apple.com/id/developer/dale-watson/id1531628326)  - [linkedin](https://linkedin/in/dellwatson) 





### The team below isn't joining hackathon and focusing on first selling plan.

**2. Esta**
a 3D artist, responsible turning the concept into 3D model that team can use in-game, in-filmmaking, or sell it as NFT. Making sure the standard 3d development across the project.
- [Instagram](https://www.instagram.com/esta.claresta/)
- [Portfolio]()
- [Linkedin](www.linkedin.com/in/claresta-lemuella)

Skills: Houdini, Maya, Blender

**3. Theodore**
a Filmmaker, a vfx specialist, responsible to create awesome trailer, and video engagement to the community.
- he doesn't have social but his work can be seen from his [teammate instagram](https://www.instagram.com/ggilbertmarch/). He works as the vfx specialist since the college 2013

Skills: Cine4D, Adobe, Unreal-Engine, Blender


**4. Siya**
Documenter, and manage schedule for events. podcast, and AMA

**5. Lamarn**
Community Manager, Mod, and take care of social media under my supervision.

**6. Leo**
a Filmmaker, a vfx specialist, responsible to create awesome trailer, and video engagement to the community.



Influencers: (These are my cousins XD)
1. Lala: [Twitter](https://twitter.com/kalalaaa__?lang=en) 
2. Keniro: [Tiktok](https://www.tiktok.com/@kenniro?lang=en) [instagram](https://www.instagram.com/kenniro_/)
3. Annie  (Shanghai based, aim for chinese market later)


In the future when team expands,  i want my early core team can lead for their respective department.