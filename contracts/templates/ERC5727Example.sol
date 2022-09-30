// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC5727/ERC5727Expirable.sol";
import "../ERC5727/ERC5727Governance.sol";
import "../ERC5727/ERC5727Delegate.sol";
import "../ERC5727/ERC5727Shadow.sol";
import "../ERC5727/ERC5727SlotEnumerable.sol";
import "../ERC5727/ERC5727Recovery.sol";

contract ERC5727Example is
    ERC5727Expirable,
    ERC5727Governance,
    ERC5727Delegate,
    ERC5727SlotEnumerable,
    ERC5727Shadow,
    ERC5727Recovery
{
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory voters,
        string memory baseTokenURI
    ) ERC5727Governance(name, symbol, voters) {
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
            ERC5727Governance,
            ERC5727Delegate,
            ERC5727Expirable,
            ERC5727Recovery,
            ERC5727Shadow,
            ERC5727SlotEnumerable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeView(uint256 tokenId)
        internal
        view
        virtual
        override(ERC5727, ERC5727Shadow)
    {
        ERC5727Shadow._beforeView(tokenId);
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
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._beforeTokenMint(
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
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._afterTokenMint(
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
        override(ERC5727, ERC5727Enumerable)
    {
        ERC5727Enumerable._afterTokenRevoke(tokenId);
    }

    function _beforeTokenDestroy(uint256 tokenId)
        internal
        virtual
        override(ERC5727, ERC5727Enumerable)
    {
        ERC5727Enumerable._beforeTokenDestroy(tokenId);
    }
}
