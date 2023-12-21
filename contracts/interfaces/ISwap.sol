// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Interface of Swap protocol
/// @author 0xdellwatson
/// @notice this standard interface for being used for other system
interface ISwap {
    /// @notice a forward payment process after bank approval
    /// @dev this will be called by protcol (ledger contract) or authorized
    /// @param _tokenAddress a parameter just like in doxygen (must be followed by parameter name)
    /// @param _recipient the user who requested the swap previously
    /// @param _amountOut amount of erc20 token
    function processPayment(
        IERC20 _tokenAddress,
        address _recipient,
        uint256 _amountOut
    ) external;
}
