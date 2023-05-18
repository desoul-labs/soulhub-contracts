//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727UpgradeableDS.sol";
import "./interfaces/IERC5727EnumerableUpgradeable.sol";
import "../ERC3525/ERC3525SlotEnumerableUpgradeableDS.sol";
import "./ERC5727EnumerableStorage.sol";

contract ERC5727EnumerableUpgradeableDS is
    IERC5727EnumerableUpgradeable,
    ERC5727UpgradeableDS,
    ERC3525SlotEnumerableUpgradeableDS
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    function init(
        string memory name_,
        string memory symbol_,
        address admin_,
        string memory baseUri_,
        string memory version_
    ) external virtual override initializer {
        __EIP712_init_unchained(name_, version_);
        __ERC721_init_unchained(name_, symbol_, baseUri_);
        __ERC3525_init_unchained(18);
        __ERC5727_init_unchained(admin_);
        __ERC5727Enumerable_init_unchained();
    }

    function __ERC5727Enumerable_init_unchained() internal onlyInitializing {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC3525UpgradeableDS, ERC5727UpgradeableDS)
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

        return LibERC5727EnumerableStorage.s()._slotsOfOwner[owner].length();
    }

    function slotOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view override returns (uint256) {
        if (owner == address(0)) revert NullValue();
        uint256 slotCountByOwner = LibERC5727EnumerableStorage
            .s()
            ._slotsOfOwner[owner]
            .length();
        if (index >= slotCountByOwner)
            revert IndexOutOfBounds(index, slotCountByOwner);

        return LibERC5727EnumerableStorage.s()._slotsOfOwner[owner].at(index);
    }

    function ownerBalanceInSlot(
        address owner,
        uint256 slot
    ) public view override returns (uint256) {
        if (owner == address(0)) revert NullValue();
        if (!_slotExists(slot)) revert NotFound(slot);

        return
            LibERC5727EnumerableStorage.s()._ownerBalanceInSlot[slot].get(
                owner
            );
    }

    function _incrementOwnerBalanceInSlot(
        address owner,
        uint256 slot
    ) internal virtual {
        if (owner == address(0)) revert NullValue();

        (, uint256 balanceInSlot) = LibERC5727EnumerableStorage
            .s()
            ._ownerBalanceInSlot[slot]
            .tryGet(owner);
        unchecked {
            LibERC5727EnumerableStorage.s()._ownerBalanceInSlot[slot].set(
                owner,
                balanceInSlot + 1
            );
        }
    }

    function _decrementOwnerBalanceInSlot(
        address owner,
        uint256 slot
    ) internal virtual {
        if (owner == address(0)) revert NullValue();

        uint256 balanceInSlot = LibERC5727EnumerableStorage
            .s()
            ._ownerBalanceInSlot[slot]
            .get(owner);
        unchecked {
            LibERC5727EnumerableStorage.s()._ownerBalanceInSlot[slot].set(
                owner,
                balanceInSlot - 1
            );
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
        override(ERC721EnumerableUpgradeable, ERC5727UpgradeableDS)
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
        override(ERC3525SlotEnumerableUpgradeableDS, ERC5727UpgradeableDS)
    {
        ERC3525SlotEnumerableUpgradeableDS._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        ERC5727UpgradeableDS._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (from == address(0) && fromTokenId == 0) {
            _incrementOwnerBalanceInSlot(to, slot);

            LibERC5727EnumerableStorage.s()._slotsOfOwner[to].add(slot);
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
        override(ERC3525SlotEnumerableUpgradeableDS, ERC3525UpgradeableDS)
    {
        ERC3525SlotEnumerableUpgradeableDS._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (to == address(0) && toTokenId == 0) {
            _decrementOwnerBalanceInSlot(from, slot);

            if (
                LibERC5727EnumerableStorage.s()._ownerBalanceInSlot[slot].get(
                    from
                ) == 0
            ) {
                LibERC5727EnumerableStorage.s()._slotsOfOwner[from].remove(
                    slot
                );
            }
        }

        value;
    }
}
