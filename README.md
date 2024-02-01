# Game Contracts README

## Overview

STAREX is a cross-chain GameFi project that requires the deployment of a set of smart contracts to each network for token wrapping and system integration.

Currently, we utilize our own backend with EIP712 security and other alternative security measures. This approach signifies that we are adopting a hybrid system and are not fully decentralized yet. This decision has been made to expedite the release process and streamline development, with a primary focus on the adoption of 2-3 networks during the first season. The hackathon is intended to provide exposure and secure additional funding to accelerate progress in other departments.

> However, we have plans to migrate towards interoperability with other protocols, such as LayerZero, Wormhole, and ChainLINK CCIP in the future.

This repository contains smart contracts that govern various aspects of our blockchain-based game.
Whether it's solidity language, cairo language, rust language. Everything is here, and for other people to learn.

These contracts facilitate the basic creation of STAREX, management, and interaction with in-game assets, transactions, and special features. Below is an overview of the key contracts and their purposes.

Due to security concern, the submission of the contracts has limited features, and not the final code.

The gameplay consist of min 3 networks which 1 will be the major network and the other are minor network. this network collaboration can promote growth and interesting gameplay. The major network not fully decided yet until our first minting on april 2024.
the major network will be a new chain while the minor network will be big network like polygon and ethereum.

## Branches Overview

- [**master:**](#master) This branch serves as the main hub for information and project overview.
- [**artela:**](https://github.com/Theras-Labs/starex-contracts-prototype/tree/artela) Submitted for Artela.
- [**areon:**](https://github.com/Theras-Labs/starex-contracts-prototype/tree/areon) Submitted for Areon .

- [**STARKNET-L2:**](https://github.com/Theras-Labs/starex-starknet-L2-contract) Using Cairo language submitted for any STARKNET hackathon.

> ⚠️ **Important Note:** Each branch may have different implementations and results, even if the hackathon duration is the same. Each Hackathons may have different developments, some focusing exclusively on mobile development or contract development. Please review the README in each branch for specific details about the submission.
