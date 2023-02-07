// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./ERC5727Enumerable.sol";
import "./interfaces/IERC5727Recovery.sol";

abstract contract ERC5727Recovery is IERC5727Recovery, ERC5727Enumerable {
    using SignatureChecker for address;

    bytes32 private constant _RECOVERY_TYPEHASH =
        keccak256("Recovery(address from,address recipient)");

    function recover(
        address from,
        bytes memory signature
    ) public virtual override {
        if (from == address(0)) revert NullValue();
        address recipient = _msgSender();
        if (from == recipient) revert MethodNotAllowed(recipient);

        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encodePacked(_RECOVERY_TYPEHASH, from, recipient))
        );
        if (!from.isValidSignatureNow(digest, signature)) revert Forbidden();

        uint256 balance = balanceOf(from);
        for (uint256 i = 0; i < balance; ) {
            uint256 tokenId = tokenOfOwnerByIndex(from, i);
            uint256 value = balanceOf(tokenId);

            _revoke(from, tokenId, value);
            _issue(
                issuerOf(tokenId),
                recipient,
                tokenId,
                value,
                slotOf(tokenId),
                burnAuth(tokenId)
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
