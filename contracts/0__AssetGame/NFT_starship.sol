// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A nft contract for starship
/// @author 0xdellwatson
contract NFT_starship is ERC1155, Ownable, ERC1155Supply {
    // State variables
    address public erc20Token;
    mapping(uint256 => uint256) public nftPrices;

  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

    constructor(address initialOwner)
        ERC1155("https://metadata/")
        Ownable(initialOwner)
    {}

    // Modifier to allow only Shop contracts to call mintFromContract
  modifier onlyShop() {
    require(
      allowedContracts[msg.sender],
      "Only allowed Shop contract can call this function"
    );
    _;
  }

    // Set the ERC20 token address
    function setERC20Token(address _erc20Token) public onlyOwner {
        erc20Token = _erc20Token;
    }

    // Set the prices for each NFT ID 
    function setNFTPrices(uint256[] memory ids, uint256[] memory prices) public onlyOwner {
        for (uint i = 0; i < ids.length; i++) {
            nftPrices[ids[i]] = prices[i];
        }
    }

    // Mint with payment (Ether or ERC20)
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public payable {
        require(msg.value == nftPrices[id] * amount || IERC20(erc20Token).transferFrom(msg.sender, address(this), nftPrices[id] * amount), "Incorrect payment");
        _mint(account, id, amount, data);
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

    // Override required functions
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
