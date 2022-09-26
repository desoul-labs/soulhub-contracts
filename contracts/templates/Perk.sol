// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC5342/ERC5342Expirable.sol";
import "../ERC5342/ERC5342Consensus.sol";
import "../ERC5342/ERC5342Delegate.sol";
import "../ERC5342/ERC5342Shadow.sol";
import "../ERC5342/ERC5342SlotEnumerable.sol";
import "../ERC5342/ERC5342Pull.sol";

contract Perk is
    ERC5342Expirable,
    ERC5342Consensus,
    ERC5342Delegate,
    ERC5342SlotEnumerable,
    ERC5342Shadow,
    ERC5342Pull
{
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory voters,
        string memory baseTokenURI
    ) ERC5342Consensus(name, symbol, voters) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            ERC5342Consensus,
            ERC5342Delegate,
            ERC5342Expirable,
            ERC5342Pull,
            ERC5342Shadow,
            ERC5342SlotEnumerable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeView(uint256 tokenId)
        internal
        view
        virtual
        override(ERC5342, ERC5342Shadow)
    {
        ERC5342Shadow._beforeView(tokenId);
    }

    function mint(
        address soul,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) public virtual onlyOwner {
        uint256 tokenId = _mint(soul, value, slot);
        if (shadowed) {
            _shadow(tokenId);
        }
        _setExpiryDate(tokenId, expiryDate);
    }

    function revoke(uint256 tokenId) public virtual onlyOwner {
        _revoke(tokenId);
    }

    function mintBatch(
        address[] memory souls,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) public virtual onlyOwner {
        uint256[] memory tokenIds = _mintBatch(souls, value, slot);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (shadowed) _shadow(tokenIds[i]);
            _setExpiryDate(tokenIds[i], expiryDate);
        }
    }

    function revokeBatch(uint256[] memory tokenIds) public virtual onlyOwner {
        _revokeBatch(tokenIds);
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
