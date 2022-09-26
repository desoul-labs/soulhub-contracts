// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC5342/ERC5342Expirable.sol";
import "../ERC5342/ERC5342Enumerable.sol";

contract SoulmateCard is ERC5342Expirable, ERC5342Enumerable {
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC5342(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC5342Enumerable, ERC5342Expirable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mintNonFungible(
        address owner,
        uint256 slot,
        uint256 date
    ) public onlyOwner returns (uint256) {
        require(slot != 0, "SoulmateCard: slot 0 is for points");
        uint256 tokenId = _mint(owner, 1, slot);
        _setExpiryDate(tokenId, date);
        return tokenId;
    }

    function mintFungible(address owner, uint256 value) public onlyOwner {
        _mint(owner, value, 0);
    }

    function charge(uint256 tokenId, uint256 value) public onlyOwner {
        require(
            _getTokenOrRevert(tokenId).slot == 0,
            "SoulmateCard: only points can be charged"
        );
        _charge(tokenId, value);
    }

    function revoke(uint256 tokenId) public onlyOwner {
        _revoke(tokenId);
    }

    function _beforeTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual override(ERC5342, ERC5342Enumerable) {
        ERC5342Enumerable._beforeTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
    }

    function _afterTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual override(ERC5342, ERC5342Enumerable) {
        ERC5342Enumerable._afterTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
    }

    function _afterTokenRevoke(uint256 tokenId)
        internal
        virtual
        override(ERC5342, ERC5342Enumerable)
    {
        ERC5342Enumerable._afterTokenRevoke(tokenId);
    }

    function _beforeTokenDestroy(uint256 tokenId)
        internal
        virtual
        override(ERC5342, ERC5342Enumerable)
    {
        ERC5342Enumerable._beforeTokenDestroy(tokenId);
    }
}
