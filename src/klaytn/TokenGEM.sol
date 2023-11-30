// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/KIP/token/KIP7/extensions/draft-KIP7Permit.sol";


contract EXGEM is KIP7, Ownable, KIP7Permit {

   constructor() KIP7("EXGEM", "GEM") KIP7Permit("EXGEM") {}

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

    function mint(address to, uint256 amount) public  {
        _mint(to, amount  * 10**18);
    }
    function mintToken(address to, uint256 amount) external   {
        _mint(to, amount  * 10**18);
    }
}
