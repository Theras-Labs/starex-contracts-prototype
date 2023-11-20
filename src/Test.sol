// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract EIP712AuthContract is Ownable, EIP712 {
  using ECDSA for bytes32;
  struct Ticket {
    bytes32 r;
    bytes32 s;
    uint8 v;
  }

  bytes32 public constant AUTH_TYPEHASH =
    keccak256("AuthMessage(address user,uint256 nonce)");
  address public whitelistSigner = address(0);
  uint256 public currentNonce;

  event WhitelistSignerSettled(address oldSigner, address newSigner);

  constructor(address initialOwner)
    Ownable(initialOwner)
    EIP712("EIP712AuthContract", "1.0.0")
  {
    currentNonce = 1;
  }

  // ============ OWNER-ONLY ADMIN FUNCTIONS ============

  function authorizeUser() external onlyOwner {
    currentNonce++;
  }

  function updateWhitelistAddressAuth(address _whitelistSigner)
    external
    onlyOwner
  {
    address prevSigner = whitelistSigner;
    whitelistSigner = _whitelistSigner;
    emit WhitelistSignerSettled(prevSigner, _whitelistSigner);
  }

  // ============ INTERNAL ============
  function _hash(address _buyer, uint256 _nonce)
    internal
    view
    returns (bytes32)
  {
    return
      _hashTypedDataV4(keccak256(abi.encode(AUTH_TYPEHASH, _buyer, _nonce)));
  }

  function _verify(bytes32 _digest, bytes memory _signature)
    internal
    view
    returns (bool)
  {
    return ECDSA.recover(_digest, _signature) == whitelistSigner;
  }

  // ============ MODIFIERS ============

  /**
   * @dev validates signature
   */

  modifier requiresWhitelist(bytes calldata _signature, uint256 _nonce) {
    require(
      _verify(_hash(msg.sender, _nonce), _signature),
      "The Signature is invalid!"
    );
    require(whitelistSigner != address(0), "Signer is default address!");

    // Verify EIP-712 signature
    // bytes32 digest = keccak256(
    //     abi.encodePacked(
    //         "\x19\x01",
    //         DOMAIN_SEPARATOR,
    //         keccak256(abi.encode(PRESALE_TYPEHASH, msg.sender))
    //     )
    // );
    // // Use the recover method to see what address was used to create
    // // the signature on this data.
    // // Note that if the digest doesn't exactly match what was signed we'll
    // // get a random recovered address.
    // address recoveredAddress = digest.recover(signature);
    // require(recoveredAddress == whitelistSigningKey, "Invalid Signature");
    _;
  }

  //   function isAuthorized(
  //     address _user,
  //     uint256 _nonce,
  //     bytes calldata _signature
  //   ) external view returns (bool) {
  //     bytes32 digest = _hash(_user, _nonce);
  //     return _verify(digest, _signature);
  //   }
  function isAuthorized(
    address _user,
    // uint256 _nonce,
    // bytes calldata _signature
    Ticket memory _ticket
  ) external view returns (bool) {
    bytes32 _digest = keccak256(abi.encode(_user));
    return isVerifiedTicket(_digest, _ticket);
  }

  function isVerifiedTicket(bytes32 _digest, Ticket memory _ticket)
    internal
    view
    returns (bool)
  {
    address signer = ecrecover(_digest, _ticket.v, _ticket.r, _ticket.s);
    require(signer != address(0), "ECDSA: invalid signature");
    return signer == whitelistSigner;
  }
}
