// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../_viction/VRC25/VRC25.sol";

/// @title A mock GEM token from parent game company
contract EXGEM is VRC25 {
  constructor(address initialOwner)
    VRC25("FAKE USD", "fUSD", 18)
  // ERC20("EX-GEM", "EX")
  // Ownable(initialOwner)
  // ERC20Permit("EX-GEM")
  {

  }

  function _estimateFee(uint256 value)
    internal
    view
    override
    returns (uint256)
  {
    // Provide your implementation here
    // For example, you might return a constant fee or calculate it based on some logic.
    return value * 1;
  }

  function mint(address to, uint256 amount) public {
    _mint(to, amount * 10**18);
  }

  function mintToken(address to, uint256 amount) external {
    _mint(to, amount * 10**18);
  }
}
