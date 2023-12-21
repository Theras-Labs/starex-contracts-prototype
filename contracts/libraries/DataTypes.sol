// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title DataTypes
/// @author 0xdellwatson

library DataTypes {
    /// @notice Containing different states the protocol can be in
    /// @param Unpaused  The fully unpaused state.
    /// @param Paused  The fully paused state.
    enum ProtocolState {
        Unpaused,
        Paused
    }
    /// @notice Containing different states for information intransaction
    /// @param Deposit the incoming transaction
    /// @param Transfer the transaction has issued to move the balance
    /// @param PaymentRequest The transaction is requested for other user like requesting bill
    enum OperationType {
        Deposit,
        Transfer,
        PaymentRequest
    }
    /// @notice An enum specifically to help differentiate between stage of transaction
    /// @param Pending A transaction need approval to move forward
    /// @param Rejected A transaction just rejected, no balance moved
    /// @param BankApproved A transaction just approved by bank can move forward
    /// @param Completed A transaction just completed and balance have been moved out
    enum OperationStatus {
        Pending,
        Rejected,
        BankApproved,
        Completed
    }

    /// @notice Struct to hold transaction information
    /// @dev - Need to differentiate the id for in and out later,
    /// @dev   so it would show on both related addresses as withdraw and deposit
    /// @dev - Need to add block timestamp for on-chain interaction
    /// @param id Id of tx from the address, and NOT global id
    /// @param amount Amount related in transaction using a single currency
    /// @param operationType Type of transaction Deposit | Transfer
    /// @param status Current status of transaction until completion
    /// @param isApprovedSender Does the client approve this?
    /// @param isApprovedBank Does the bank approve this?
    /// @param bankApprover The address of the bank who approves, in case of a change of bank-address
    /// @param initiator Address who is requesting this tx
    /// @param sender Address value account comes from
    /// @param recipient Address value account goes to
    struct Transaction {
        uint256 id;
        uint256 amount;
        OperationType operationType;
        OperationStatus status;
        bool isApprovedSender;
        bool isApprovedBank;
        address bankApprover;
        address initiator;
        address sender;
        address recipient;
    }

    /// @notice List information of a available pool to swap
    /// @dev As we dont want any ERC20 token to be able swapped with ledger's currency (meme token etc)
    /// @param id id of pool
    /// @param fee fee of using this pool
    /// @param minAmount min amount for this pool
    /// @param maxAmount max amount for this pool
    /// @param tokenAddress address of the token WETH, WBTC, WABC
    /// @param aggregatorAddress aggregator data price we use
    /// @param tokenName aggregator pool name (WETH/USD BTC/USD)
    /// having string is fine since it's not that many we stored this pool, and often
    /// unless having ERC20-ERC20 without against ledger's currency, WETH/WBTC (incase we are in USD)
    struct PoolDetails {
        uint256 id;
        uint256 fee;
        uint256 minAmount;
        uint256 maxAmount;
        address tokenAddress;
        address aggregatorAddress;
        string tokenName;
    }
}
