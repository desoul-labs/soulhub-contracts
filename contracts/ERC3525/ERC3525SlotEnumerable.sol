// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import "./ERC3525.sol";
import "./interfaces/IERC3525SlotEnumerable.sol";

abstract contract ERC3525SlotEnumerable is ERC3525, IERC3525SlotEnumerable {
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(uint256 => EnumerableSet.UintSet) private _tokensInSlot;

    EnumerableSet.UintSet internal _allSlots;

    function slotCount() public view virtual override returns (uint256) {
        return _allSlots.length();
    }

    function slotByIndex(
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index >= _allSlots.length())
            revert IndexOutOfBounds(index, _allSlots.length());

        return _allSlots.at(index);
    }

    function _slotExists(uint256 slot) internal view virtual returns (bool) {
        return _allSlots.length() > 0 && _allSlots.contains(slot);
    }

    function tokenSupplyInSlot(
        uint256 slot
    ) public view virtual override returns (uint256) {
        if (!_slotExists(slot)) revert NotFound(slot);

        return _tokensInSlot[slot].length();
    }

    function tokenInSlotByIndex(
        uint256 slot,
        uint256 index
    ) external view virtual override returns (uint256) {
        if (!_slotExists(slot)) revert NotFound(slot);
        if (index >= _tokensInSlot[slot].length())
            revert IndexOutOfBounds(index, _tokensInSlot[slot].length());

        return _tokensInSlot[slot].at(index);
    }

    function _tokenCountInSlot(
        uint256 slot
    ) internal view virtual returns (uint256) {
        return _tokensInSlot[slot].length();
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override {
        ERC3525._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (from == address(0) && fromTokenId == 0) {
            if (!_slotExists(slot)) {
                _allSlots.add(slot);
            }

            _tokensInSlot[slot].add(toTokenId);
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
        ERC3525._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        if (to == address(0) && toTokenId == 0) {
            _tokensInSlot[slot].remove(fromTokenId);

            if (_tokenCountInSlot(slot) == 0) {
                _allSlots.remove(slot);
            }
        }

        value;
    }
}
