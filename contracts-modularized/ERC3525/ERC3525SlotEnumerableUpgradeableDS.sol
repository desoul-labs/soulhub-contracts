// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";

import "./ERC3525UpgradeableDS.sol";
import "./interfaces/IERC3525SlotEnumerableUpgradeable.sol";
import "./ERC3525Storage.sol";

abstract contract ERC3525SlotEnumerableUpgradeableDS is
    ERC3525UpgradeableDS,
    IERC3525SlotEnumerableUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    function __ERC3525SlotEnumerable_init() internal onlyInitializing {
        __ERC3525SlotEnumerable_init_unchained();
    }

    function __ERC3525SlotEnumerable_init_unchained()
        internal
        onlyInitializing
    {}

    function slotCount() public view virtual override returns (uint256) {
        return LibERC3525SlotEnumerableStorage.s()._allSlots.length();
    }

    function slotByIndex(
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index >= LibERC3525SlotEnumerableStorage.s()._allSlots.length())
            revert IndexOutOfBounds(
                index,
                LibERC3525SlotEnumerableStorage.s()._allSlots.length()
            );

        return LibERC3525SlotEnumerableStorage.s()._allSlots.at(index);
    }

    function _slotExists(uint256 slot) internal view virtual returns (bool) {
        return
            LibERC3525SlotEnumerableStorage.s()._allSlots.length() > 0 &&
            LibERC3525SlotEnumerableStorage.s()._allSlots.contains(slot);
    }

    function tokenSupplyInSlot(
        uint256 slot
    ) public view virtual override returns (uint256) {
        if (!_slotExists(slot)) revert NotFound(slot);

        return LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].length();
    }

    function tokenInSlotByIndex(
        uint256 slot,
        uint256 index
    ) external view virtual override returns (uint256) {
        if (!_slotExists(slot)) revert NotFound(slot);
        if (
            index >=
            LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].length()
        )
            revert IndexOutOfBounds(
                index,
                LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].length()
            );

        return
            LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].at(index);
    }

    function _tokenCountInSlot(
        uint256 slot
    ) internal view virtual returns (uint256) {
        return LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].length();
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override {
        ERC3525UpgradeableDS._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (from == address(0) && fromTokenId == 0) {
            if (!_slotExists(slot)) {
                LibERC3525SlotEnumerableStorage.s()._allSlots.add(slot);
            }

            LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].add(
                toTokenId
            );
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
    ) internal virtual override {
        ERC3525UpgradeableDS._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (to == address(0) && toTokenId == 0) {
            LibERC3525SlotEnumerableStorage.s()._tokensInSlot[slot].remove(
                fromTokenId
            );

            if (_tokenCountInSlot(slot) == 0) {
                LibERC3525SlotEnumerableStorage.s()._allSlots.remove(slot);
            }
        }

        value;
    }
}
