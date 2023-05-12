//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727EnumerableUpgradeable.sol";
import "../ERC3525/ERC3525SlotEnumerableUpgradeable.sol";

abstract contract ERC5727EnumerableUpgradeable is
    IERC5727EnumerableUpgradeable,
    ERC5727Upgradeable,
    ERC3525SlotEnumerableUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    mapping(address => EnumerableSetUpgradeable.UintSet) private _slotsOfOwner;

    mapping(uint256 => EnumerableMapUpgradeable.AddressToUintMap)
        private _ownerBalanceInSlot;

    function __ERC5727Enumerable_init() internal onlyInitializing {
        __ERC5727Enumerable_init_unchained();
    }

    function __ERC5727Enumerable_init_unchained() internal onlyInitializing {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC3525Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function slotCountOfOwner(
        address owner
    ) external view override returns (uint256) {
        if (owner == address(0)) revert NullValue();

        return _slotsOfOwner[owner].length();
    }

    function slotOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view override returns (uint256) {
        if (owner == address(0)) revert NullValue();
        uint256 slotCountByOwner = _slotsOfOwner[owner].length();
        if (index >= slotCountByOwner)
            revert IndexOutOfBounds(index, slotCountByOwner);

        return _slotsOfOwner[owner].at(index);
    }

    function ownerBalanceInSlot(
        address owner,
        uint256 slot
    ) public view returns (uint256) {
        if (owner == address(0)) revert NullValue();
        if (!_slotExists(slot)) revert NotFound(slot);

        return _ownerBalanceInSlot[slot].get(owner);
    }

    function _incrementOwnerBalanceInSlot(
        address owner,
        uint256 slot
    ) internal virtual {
        if (owner == address(0)) revert NullValue();

        (, uint256 balanceInSlot) = _ownerBalanceInSlot[slot].tryGet(owner);
        unchecked {
            _ownerBalanceInSlot[slot].set(owner, balanceInSlot + 1);
        }
    }

    function _decrementOwnerBalanceInSlot(
        address owner,
        uint256 slot
    ) internal virtual {
        if (owner == address(0)) revert NullValue();

        uint256 balanceInSlot = _ownerBalanceInSlot[slot].get(owner);
        unchecked {
            _ownerBalanceInSlot[slot].set(owner, balanceInSlot - 1);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC5727Upgradeable)
    {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    )
        internal
        virtual
        override(ERC3525SlotEnumerableUpgradeable, ERC5727Upgradeable)
    {
        super._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (from == address(0) && fromTokenId == 0) {
            _incrementOwnerBalanceInSlot(to, slot);

            _slotsOfOwner[to].add(slot);
        }

        value;
    }

    function _afterValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    )
        internal
        virtual
        override(ERC3525SlotEnumerableUpgradeable, ERC3525Upgradeable)
    {
        super._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (to == address(0) && toTokenId == 0) {
            _decrementOwnerBalanceInSlot(from, slot);

            if (_ownerBalanceInSlot[slot].get(from) == 0) {
                _slotsOfOwner[from].remove(slot);
            }
        }

        value;
    }
}
