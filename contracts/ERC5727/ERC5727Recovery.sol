// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./ERC5727Enumerable.sol";
import "./interfaces/IERC5727Recovery.sol";

abstract contract ERC5727Recovery is IERC5727Recovery, ERC5727Enumerable {
    using SignatureChecker for address;

    mapping(address => uint256) private _challengeDeadlines;
    uint256 private _minDuration = 1 days;

    bytes32 private constant _RECOVERY_TYPEHASH =
        keccak256("Recovery(address from,address recipient)");

    function recover(
        address from,
        bytes memory signature
    ) public virtual override {
        if (from == address(0)) revert NullValue();
        address recipient = _msgSender();
        if (from == recipient) revert MethodNotAllowed(recipient);
        if (block.timestamp < _challengeDeadlines[from])
            revert RecoveryPending(from, recipient);

        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encodePacked(_RECOVERY_TYPEHASH, from, recipient))
        );
        if (!from.isValidSignatureNow(digest, signature)) revert Forbidden();

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

    // function _schedule(address from, uint256 duration) private {
    //     if (duration < challengeDuration()) revert InsufficientDelay();
    //     _challengeDeadlines[from] = block.timestamp + duration;
    // }

    function tryRecover(
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

        _challengeDeadlines[from] = block.timestamp + _minDuration;

        emit Recover(from, _challengeDeadlines[from]);
    }

    function challengeRecovery(address from) public virtual override {
        if (from == address(0)) revert NullValue();
        if (_challengeDeadlines[from] == 0) revert Challenge(from);
        delete _challengeDeadlines[from];

        emit RecoveryChallenged(from);
    }

    function challengeDuration() public view virtual returns (uint256) {
        return _minDuration;
    }

    function challengeDeadline(
        address from
    ) public view virtual returns (uint256) {
        return _challengeDeadlines[from];
    }
}
