// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// contract EIP712AuthContract is Ownable, EIP712 {
//     using ECDSA for bytes32;

//     bytes32 public constant AUTH_TYPEHASH = keccak256("AuthMessage(address user,uint256 nonce)");
//     uint256 public currentNonce;

//     constructor() EIP712("EIP712AuthContract", "1.0.0") {
//         currentNonce = 1;
//     }

//     function authorizeUser(address _user) external onlyOwner {
//         currentNonce++;
//     }

//     function isAuthorized(address _user, uint256 _nonce, bytes memory _signature) external view returns (bool) {
//         AuthMessage memory message = AuthMessage(_user, _nonce);
//         bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(AUTH_TYPEHASH, message.user, message.nonce)));
//         address signer = digest.recover(_signature);
//         return signer == owner();
//     }
// }
