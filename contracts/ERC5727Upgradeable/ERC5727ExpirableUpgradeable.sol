//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727ExpirableUpgradeable.sol";

abstract contract ERC5727ExpirableUpgradeable is
    IERC5727ExpirableUpgradeable,
    ERC5727Upgradeable
{
    mapping(uint256 => uint256) private _expiryDate;

    function __ERC5727Expirable_init_unchained() internal onlyInitializing {}

    function __ERC5727Expirable_init() internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        __ERC5727Expirable_init_unchained();
    }

    function expiryDate(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 date = _expiryDate[tokenId];
        require(date != 0, "ERC5727Expirable: No expiry date set");
        return date;
    }

    function isExpired(uint256 tokenId)
        public
        view
        virtual
        override
        returns (bool)
    {
        uint256 date = _expiryDate[tokenId];
        require(date != 0, "ERC5727Expirable: No expiry date set");
        return date < block.timestamp;
    }

    function _setExpiryDate(uint256 tokenId, uint256 date)
        internal
        virtual
        onlyOwner
    {
        require(
            date > block.timestamp,
            "ERC5727Expirable: Expiry date cannot be in the past"
        );
        require(
            date > _expiryDate[tokenId],
            "ERC5727Expirable: Expiry date can only be extended"
        );
        _expiryDate[tokenId] = date;
    }

    function _setBatchExpiryDates(
        uint256[] memory tokenIds,
        uint256[] memory dates
    ) internal {
        require(
            tokenIds.length == dates.length,
            "ERC5727Expirable: Ids and token URIs length mismatch"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setExpiryDate(tokenIds[i], dates[i]);
        }
    }

    function _setBatchExpiryDates(uint256[] memory tokenIds, uint256 date)
        internal
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setExpiryDate(tokenIds[i], date);
        }
    }

    function setExpiryDate(uint256 tokenId, uint256 date) public onlyOwner {
        _setExpiryDate(tokenId, date);
    }

    function setBatchExpiryDates(
        uint256[] memory tokenIds,
        uint256[] memory dates
    ) public onlyOwner {
        _setBatchExpiryDates(tokenIds, dates);
    }

    function supportsInterface(bytes4 interfaceId)
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
