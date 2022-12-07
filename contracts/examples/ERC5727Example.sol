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

    function supportsInterface(
        bytes4 interfaceId
    )
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

    function _beforeView(
        uint256 tokenId
    ) internal view virtual override(ERC5727, ERC5727Shadow) {
        ERC5727Shadow._beforeView(tokenId);
    }

    function mint(
        address soul,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) external payable virtual onlyOwner {
        uint256 tokenId = _mint(soul, value, slot);
        if (shadowed) {
            _shadow(tokenId);
        }
        _setExpiryDate(tokenId, expiryDate);
    }

    function revoke(uint256 tokenId) external virtual onlyOwner {
        _revoke(tokenId);
    }

    function mintBatch(
        address[] calldata souls,
        uint256[] calldata values,
        uint256[] calldata slots,
        uint256[] calldata expiryDates,
        bool[] calldata shadowed
    ) external payable virtual onlyOwner {
        uint256[] memory tokenIds = _mintBatch(souls, values, slots);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (shadowed[i]) _shadow(tokenIds[i]);
            _setExpiryDate(tokenIds[i], expiryDates[i]);
        }
    }

    function revokeBatch(
        uint256[] calldata tokenIds
    ) external virtual onlyOwner {
        _revokeBatch(tokenIds);
    }

    function _beforeTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    )
        internal
        virtual
        override(ERC5727, ERC5727Enumerable, ERC5727SlotEnumerable)
    {
        ERC5727Enumerable._beforeTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
        ERC5727SlotEnumerable._beforeTokenMint(
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

    function _afterTokenRevoke(
        uint256 tokenId
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._afterTokenRevoke(tokenId);
    }

    function _beforeTokenDestroy(
        uint256 tokenId
    )
        internal
        virtual
        override(ERC5727, ERC5727Enumerable, ERC5727SlotEnumerable)
    {
        ERC5727Enumerable._beforeTokenDestroy(tokenId);
        ERC5727SlotEnumerable._beforeTokenDestroy(tokenId);
    }

    function valueOf_(uint256 tokenId) external virtual returns (uint256) {
        _beforeView(tokenId);
        return valueOf(tokenId);
    }

    function tokenOf(
        uint256 tokenId
    ) external view virtual returns (Token memory) {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId);
    }
}
