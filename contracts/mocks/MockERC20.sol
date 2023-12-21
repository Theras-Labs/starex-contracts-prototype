// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Currency is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // The ERC20 constructor now sets the name and symbol
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}