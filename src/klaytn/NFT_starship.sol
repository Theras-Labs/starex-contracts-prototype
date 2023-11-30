// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@klaytn/contracts/KIP/token/KIP37/KIP37.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/KIP/token/KIP37/extensions/KIP37Supply.sol";
import "@klaytn/contracts/KIP/interfaces/IKIP7.sol";

contract EX_STARSHIP is KIP37, Ownable, KIP37Supply {
    // State variables
    address public paymentToken;
    mapping(uint256 => uint256) public nftPrices;

  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

   constructor() KIP37("https://starshipmetadata") {}

    // Modifier to allow only Shop contracts to call mintFromContract
  modifier onlyShop() {
    require(
      allowedContracts[msg.sender],
      "Only allowed Shop contract can call this function"
    );
    _;
  }

  function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }


    // Set the ERC20 token address
    function setpaymentToken(address _paymentToken) public onlyOwner {
        paymentToken = _paymentToken;
    }

    // Set the prices for each NFT ID 
    function setNFTPrices(uint256[] memory ids, uint256[] memory prices) public onlyOwner {
        for (uint i = 0; i < ids.length; i++) {
            nftPrices[ids[i]] = prices[i];
        }
    }

    // Mint with payment (Ether or ERC20)
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public payable {
        require(msg.value == nftPrices[id] * amount || IKIP7(paymentToken).transferFrom(msg.sender, address(this), nftPrices[id] * amount), "Incorrect payment");
        _mint(account, id, amount, data);
    }

       function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
        onlyShop()
    {
        _mintBatch(to, ids, amounts, data);
    }

      // Function to mint tokens from another contract
  function mintCollectibleId(
    address to,
    uint256 tokenId,
    uint256 amount
  ) public onlyShop {
    // require(tokenTotalSupply[tokenId] >= amount, "Exceeds token total supply");
    _mint(to, tokenId, amount, "");

    // there's asset not depends on supply, todo: update fn ssetup of tokenid
    // tokenTotalSupply[tokenId] -= amount;
  }

     // Function for the owner to add an allowed contract
  function addAllowedContract(address contractAddress) public onlyOwner {
      allowedContracts[contractAddress] = true;
  }

  // Function for the owner to remove an allowed contract
  function removeAllowedContract(address contractAddress) public onlyOwner {
      allowedContracts[contractAddress] = false;
  }


    // Airdrop function
  function airdrop(address[] memory recipients, uint256 id, uint256 amount) public onlyOwner {
      for (uint i = 0; i < recipients.length; i++) {
          _mint(recipients[i], id, amount, "");
      }
  }

  // Query price of NFT ID
  function getPrice(uint256 id) public view returns (uint256) {
      return nftPrices[id];
  }
  
}
