//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727Core.sol";
import "./interfaces/IERC5727ExpirableUpgradeable.sol";
import "./ERC5727Storage.sol";
import "./ERC5727ExpirableUpgradeableStorage.sol";

contract ERC5727ExpirableUpgradeableDS is
    IERC5727ExpirableUpgradeable,
    ERC5727Core
{
    modifier onlyManager(uint256 tokenId) {
        if (
            _msgSender() != LibERC5727Storage.s()._issuers[tokenId] &&
            _msgSender() != ownerOf(tokenId)
        ) revert Unauthorized(_msgSender());
        _;
    }

    function setExpiration(
        uint256 tokenId,
        uint64 expiration,
        bool renewable
    ) public virtual override onlyIssuer(tokenId) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (expiration == 0) revert NullValue();
        if (LibERC5727ExpirableStorage.s()._expiryDate[tokenId] > 0)
            revert Conflict(tokenId);
        // solhint-disable-next-line not-rely-on-time
        if (expiration < block.timestamp) revert PastDate();

        LibERC5727ExpirableStorage.s()._expiryDate[tokenId] = expiration;
        LibERC5727ExpirableStorage.s()._isRenewable[tokenId] = renewable;

        emit SubscriptionUpdate(tokenId, expiration);
    }

    function renewSubscription(
        uint256 tokenId,
        uint64 duration
    ) external payable virtual override onlyManager(tokenId) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (duration == 0) revert NullValue();
        if (!LibERC5727ExpirableStorage.s()._isRenewable[tokenId])
            revert NotRenewable(tokenId);
        // solhint-disable-next-line not-rely-on-time
        if (
            LibERC5727ExpirableStorage.s()._expiryDate[tokenId] <
            block.timestamp
        ) revert Expired(tokenId);

        unchecked {
            LibERC5727ExpirableStorage.s()._expiryDate[tokenId] += duration;
        }

        emit SubscriptionUpdate(
            tokenId,
            LibERC5727ExpirableStorage.s()._expiryDate[tokenId]
        );
    }

    function cancelSubscription(
        uint256 tokenId
    ) external payable virtual override onlyManager(tokenId) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (!LibERC5727ExpirableStorage.s()._isRenewable[tokenId])
            revert NotRenewable(tokenId);
        // solhint-disable-next-line not-rely-on-time
        if (
            LibERC5727ExpirableStorage.s()._expiryDate[tokenId] <
            block.timestamp
        ) revert Expired(tokenId);

        delete LibERC5727ExpirableStorage.s()._expiryDate[tokenId];
        delete LibERC5727ExpirableStorage.s()._isRenewable[tokenId];

        emit SubscriptionUpdate(tokenId, 0);
    }

    function isRenewable(
        uint256 tokenId
    ) public view virtual override returns (bool) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        return LibERC5727ExpirableStorage.s()._isRenewable[tokenId];
    }

    function expiresAt(
        uint256 tokenId
    ) public view virtual override returns (uint64) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (LibERC5727ExpirableStorage.s()._expiryDate[tokenId] == 0)
            revert NoExpiration(tokenId);
        return LibERC5727ExpirableStorage.s()._expiryDate[tokenId];
    }
}
