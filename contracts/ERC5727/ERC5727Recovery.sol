// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./ERC5727Enumerable.sol";
import "./interfaces/IERC5727Recovery.sol";

abstract contract ERC5727Recovery is IERC5727Recovery, ERC5727Enumerable {
    using SignatureChecker for address;
    using ECDSA for bytes32;

    function recover(
        address from,
        bytes memory signature
    ) public virtual override {
        address recipient = _msgSender();
        bytes32 messageHash = keccak256(abi.encodePacked(from, recipient));
        bytes32 signedHash = messageHash.toEthSignedMessageHash();
        if (!from.isValidSignatureNow(signedHash, signature))
            revert Forbidden();

        uint256 balance = balanceOf(from);
        for (uint256 i = 0; i < balance; ) {
            uint256 tokenId = tokenOfOwnerByIndex(from, i);
            Token memory token = getToken(tokenId);

            _revoke(from, tokenId, token.value);
            _issue(
                token.issuer,
                recipient,
                tokenId,
                token.value,
                token.slot,
                token.burnAuth
            );

            unchecked {
                i++;
            }
        }

        emit Recovered(from, recipient);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727Enumerable) returns (bool) {
        return
            interfaceId == type(IERC5727Recovery).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
