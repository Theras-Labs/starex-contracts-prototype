
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/KIP/token/KIP7/extensions/draft-KIP7Permit.sol";

error EX__NotStore(address sender);
error EX__NotOwner(address sender);
error EX__ZeroPoints(address sender);
error EX__AddressZero();

contract EXPOINTS is KIP7, Ownable, KIP7Permit {
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

 constructor() KIP7("EXPOINTS", "POINT") KIP7Permit("EXPOINTS") {}

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

        function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IKIP7Permit).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
