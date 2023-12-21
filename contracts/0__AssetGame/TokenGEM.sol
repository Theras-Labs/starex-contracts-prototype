// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @title A mock GEM token from parent game company 
contract EXGEM is ERC20, Ownable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("EX-GEM", "EX")
        Ownable(initialOwner)
        ERC20Permit("EX-GEM")
    {}

    function mint(address to, uint256 amount) public  {
        _mint(to, amount  * 10**18);
    }
    function mintToken(address to, uint256 amount) external   {
        _mint(to, amount  * 10**18);
    }
}
