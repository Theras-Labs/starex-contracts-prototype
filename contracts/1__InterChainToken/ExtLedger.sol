/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PaymasterLedger.sol";
import "../interfaces/ISwap.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Extended Ledger with Swap Protocol Integration
/// @author 0xdellwatson
/// @dev A simple ledger contract to manage transactions and balances with added functionality for swap protocols.
/// @notice This contract extends the functionality of the PaymasterLedger contract to support swap protocols.
contract ExtendedLedger is PaymasterLedger {
    using SafeERC20 for IERC20;

    // Update to track ERC20 tokens to repay
    mapping(address => mapping(uint256 => IERC20)) internal s_tokenPaymentUsed;
    // Update to track ERC20 amounts to repay
    mapping(address => mapping(uint256 => uint256))
        internal s_tokenPaymentAmount;

    constructor(
        address _bank,
        address _operator,
        uint256 _minAmount,
        uint256 _maxAmount
    ) PaymasterLedger(_bank, _operator, _minAmount, _maxAmount) {}

    /// @notice Forward token information from the operator protocol.
    /// @param _fromAddress The user who initiates the swap.
    /// @param _amountPayout User's amount paying from the swap.
    /// @param _data Byte data for ERC20's info and anything.
    /// @dev Only callable by the operator.
    function reimbursedToken(
        address _fromAddress,
        uint256 _amountPayout,
        bytes calldata _data
    ) external onlyOperator {
        // Recover ERC20's user data
        (IERC20 tokenAddress, uint256 amountReimbursed) = abi.decode(
            _data,
            (IERC20, uint256)
        );

        // Since not every transaction is ERC20-involved, and we don't need to restructure the previous one.
        // So just reuse the function here.
        // msg.snder : ledger contract, _toAddress: recipient/user
        // or we can change into s_operator
        uint256 idTransaction = super.transferFrom(
            _fromAddress,
            msg.sender,
            _amountPayout
        );

        // Record which ERC20 token was used and the amount here
        s_tokenPaymentUsed[_fromAddress][idTransaction] = tokenAddress;
        s_tokenPaymentAmount[_fromAddress][idTransaction] = amountReimbursed;

        // Emit event with ERC20 amount and address, and USD
        // emit(erc20 amount and address, and usd )
    }

    /// @notice override update balance
    /// @dev add additional check to forward the ERC20
    /// @param _from The sender's address.
    /// @param _to The recipient's address.
    /// @param _amount The amount to transfer.
    /// @param _id The identifier for the transaction.
    function _updateBalance(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _id
    ) internal override {
        // Need to warn USD in and out?
        super._updateBalance(_from, _to, _amount, _id);

        // Note: Need a condition here to prevent users from trying to send to s_operator with a different ID.
        // For example, a previous payment unprocessed trying to exploit the difference and arbitrage.
        // But it should be ok for now as it won't be able to proceed further.

        if (_to == s_operator) {
            // Send the ERC20 back or set a claim state?
            // Note: Likely need to wait, as there's a chance there's no liquidity anymore.

            // Retrieve the ID here to pay forward
            IERC20 tokenAddress = s_tokenPaymentUsed[_from][_id];
            uint256 amountReimbursed = s_tokenPaymentAmount[_from][_id];

            // Should do a check for swap liquidity availability, possibly using a deadline and reserve, similar to Uniswap
            // A throw or revert if the swap has no liquidity because of differences in time between bank approval or withdrawal
            // The best approach is using a DEADLINE + RESERVE like Uniswap
            ISwap(s_operator).processPayment(
                tokenAddress,
                _from,
                amountReimbursed
            );
        }

        // Emit: approved and goes

        // Note: If not successful ERC20 transfer, stored in claim/redeem?
    }
}
