// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title Library for intended events here
/// @author 0xdellwatson

library Events {
    event TransactionProcessed(
        address indexed from,
        uint256 transactionId,
        bool approved
    );

    event BalanceMovement(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event TokensSwapped(address indexed user, uint256 amountOut);
    // / Optionally, emit an event to log the addition of PoolDetails
    event PoolDetailsAdded(
        uint256 poolId,
        address tokenAddress,
        string tokenName
    );
}
