// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract AssetContract is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
  // Mapping to store allowed contracts for minting
  mapping(address => bool) public allowedContracts;

  constructor(address initialOwner)
    ERC1155("https://metadata/season-pass")
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

  // Function to add an allowed contract
  function addAllowedContract(address contractAddress) public onlyOwner {
    allowedContracts[contractAddress] = true;
  }

  // Function to remove an allowed contract
  function removeAllowedContract(address contractAddress) public onlyOwner {
    allowedContracts[contractAddress] = false;
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

  function setURI(string memory newuri) public onlyOwner {
    _setURI(newuri);
  }

  function mint(
    address account,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public onlyOwner {
    _mint(account, id, amount, data);
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public onlyShop {
    _mintBatch(to, ids, amounts, data);
  }

  // The following functions are overrides required by Solidity.

  function _update(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values
  ) internal override(ERC1155, ERC1155Supply) {
    super._update(from, to, ids, values);
  }

  // this will be used by crafting operator:
  // note: instead of burn, locked it into operator?
  // Override the burn function with onlyShop modifier
  function burn(
    address account,
    uint256 id,
    uint256 value
  ) public override onlyShop {
    super.burn(account, id, value);
  }

  // Override the burnBatch function with onlyShop modifier
  function burnBatch(
    address account,
    uint256[] memory ids,
    uint256[] memory values
  ) public override onlyShop {
    super.burnBatch(account, ids, values);
  }
}
