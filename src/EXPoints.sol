
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

error EX__NotStore(address sender);
error EX__NotOwner(address sender);
error EX__ZeroPoints(address sender);
error EX__AddressZero();

contract ExPoints is ERC20, Ownable, ERC20Permit {
       address public store;

    event PointsIssued(address indexed sender, uint256 indexed points);
    event PointsRedeemed(address indexed sender, uint256 indexed points);

    // Mapping to store allowed contracts for minting
    mapping(address => bool) public allowedContracts;
  
        // Modifier to allow only Shop contracts to call mintFromShopContract
    modifier onlyShop() {
        require(allowedContracts[msg.sender], "Only allowed Shop contract can call this function");
        _;
    }

    constructor(address initialOwner)
        ERC20("ExPoints", "EXPoints")
        Ownable(initialOwner)
        ERC20Permit("ExPoints")
    {}

    function mintToken(address to, uint256 points) external onlyShop {
        _mint(to, points * 10**18);
        emit PointsIssued(to, points);
    }

    function redeemPoints(uint256 amount) external {
        if (amount == 0) revert EX__ZeroPoints(msg.sender);
        _burn(msg.sender, amount * 10**18);
        emit PointsRedeemed(msg.sender, amount);
    }

    // Function for the owner to add an allowed contract
    function addAllowedContract(address contractAddress) public onlyOwner {
        allowedContracts[contractAddress] = true;
    }

    // Function for the owner to remove an allowed contract
    function removeAllowedContract(address contractAddress) public onlyOwner {
        allowedContracts[contractAddress] = false;
    }
}
