//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727ExpirableUpgradeable.sol";

abstract contract ERC5727ExpirableUpgradeable is
    IERC5727ExpirableUpgradeable,
    ERC5727Upgradeable
{
    mapping(uint256 => uint64) private _expiryDate;
    mapping(uint256 => bool) private _isRenewable;

    mapping(uint256 => uint64) private _slotExpiryDate;
    mapping(uint256 => bool) private _slotIsRenewable;

    modifier onlyManager(uint256 tokenId) {
        if (
            _msgSender() != _issuers[tokenId] &&
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
        if (_expiryDate[tokenId] > 0) revert Conflict(tokenId);
        // solhint-disable-next-line not-rely-on-time
        if (expiration < block.timestamp) revert PastDate();

        _expiryDate[tokenId] = expiration;
        _isRenewable[tokenId] = renewable;

        emit SubscriptionUpdate(tokenId, expiration);
    }

    function renewSubscription(
        uint256 tokenId,
        uint64 duration
    ) external payable virtual override onlyManager(tokenId) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (duration == 0) revert NullValue();
        if (!_isRenewable[tokenId]) revert NotRenewable(tokenId);
        // solhint-disable-next-line not-rely-on-time
        if (_expiryDate[tokenId] < block.timestamp) revert Expired(tokenId);

        unchecked {
            _expiryDate[tokenId] += duration;
        }

        emit SubscriptionUpdate(tokenId, _expiryDate[tokenId]);
    }

    function cancelSubscription(
        uint256 tokenId
    ) external payable virtual override onlyManager(tokenId) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (!_isRenewable[tokenId]) revert NotRenewable(tokenId);
        // solhint-disable-next-line not-rely-on-time
        if (_expiryDate[tokenId] < block.timestamp) revert Expired(tokenId);

        delete _expiryDate[tokenId];
        delete _isRenewable[tokenId];

        emit SubscriptionUpdate(tokenId, 0);
    }

    function isRenewable(
        uint256 tokenId
    ) public view virtual override returns (bool) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        return _isRenewable[tokenId];
    }

    function expiresAt(
        uint256 tokenId
    ) public view virtual override returns (uint64) {
        if (!_exists(tokenId)) revert NotFound(tokenId);
        if (_expiryDate[tokenId] == 0) revert NoExpiration(tokenId);
        return _expiryDate[tokenId];
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727ExpirableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
