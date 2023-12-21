// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title Interface for extended Payment Ledger
/// @author 0xdellwatson
interface IExtendedLedger {
    /// @notice Forward token information from the operator protocol.
    /// @param _fromAddress The user who initiates the swap.
    /// @param _amountPayout User's amount paying from the swap.
    /// @param _data Byte data for ERC20's info and anything.
    /// @dev Only callable by the operator.
    function reimbursedToken(
        address _fromAddress,
        uint256 _amountPayout,
        bytes memory _data
    ) external;

    function deposit(address _recepient, uint256 _amountOut) external;

    function balanceOf(address _user) external view returns (uint256);
}
