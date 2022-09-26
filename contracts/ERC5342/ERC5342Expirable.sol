//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5342.sol";
import "./IERC5342Expirable.sol";

abstract contract ERC5342Expirable is IERC5342Expirable, ERC5342 {
    mapping(uint256 => uint256) private _expiryDate;

    function expiryDate(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 date = _expiryDate[tokenId];
        require(date != 0, "ERC5342Expirable: No expiry date set");
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
        require(date != 0, "ERC5342Expirable: No expiry date set");
        return date < block.timestamp;
    }

    function _setExpiryDate(uint256 tokenId, uint256 date)
        internal
        virtual
        onlyOwner
    {
        require(
            date > block.timestamp,
            "ERC5342Expirable: Expiry date cannot be in the past"
        );
        require(
            date > _expiryDate[tokenId],
            "ERC5342Expirable: Expiry date can only be extended"
        );
        _expiryDate[tokenId] = date;
    }

    function _setBatchExpiryDates(
        uint256[] memory tokenIds,
        uint256[] memory dates
    ) internal {
        require(
            tokenIds.length == dates.length,
            "ERC5342Expirable: Ids and token URIs length mismatch"
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
        override(IERC165, ERC5342)
        returns (bool)
    {
        return
            interfaceId == type(IERC5342Expirable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
