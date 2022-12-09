//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ERC5727.sol";
import "./interfaces/IERC5727SlotEnumerable.sol";

abstract contract ERC5727SlotEnumerable is ERC5727, IERC5727SlotEnumerable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => EnumerableSet.UintSet) private _tokensInSlot;

    mapping(uint256 => EnumerableSet.AddressSet) private _soulsInSlot;

    mapping(address => EnumerableSet.UintSet) private _slotsOfSoul;

    EnumerableSet.UintSet private _allSlots;

    function slotCount() public view override returns (uint256) {
        return _allSlots.length();
    }

    function slotByIndex(uint256 index) public view override returns (uint256) {
        require(
            index < ERC5727SlotEnumerable.slotCount(),
            "ERC5727SlotEnumerable: slot index out of bounds"
        );
        return _allSlots.at(index);
    }

    function _slotExists(uint256 slot) internal view virtual returns (bool) {
        return _allSlots.length() != 0 && _allSlots.contains(slot);
    }

    function tokenSupplyInSlot(
        uint256 slot
    ) public view override returns (uint256) {
        if (!_slotExists(slot)) {
            return 0;
        }
        return _tokensInSlot[slot].length();
    }

    function tokenInSlotByIndex(
        uint256 slot,
        uint256 index
    ) public view override returns (uint256) {
        require(
            index < ERC5727SlotEnumerable.tokenSupplyInSlot(slot),
            "ERC5727SlotEnumerable: slot token index out of bounds"
        );
        return _tokensInSlot[slot].at(index);
    }

    function soulsInSlot(uint256 slot) public view override returns (uint256) {
        if (!_slotExists(slot)) {
            return 0;
        }
        return _soulsInSlot[slot].length();
    }

    function soulInSlotByIndex(
        uint256 slot,
        uint256 index
    ) public view override returns (address) {
        require(
            index < ERC5727SlotEnumerable.soulsInSlot(slot),
            "ERC5727SlotEnumerable: slot soul index out of bounds"
        );
        return _soulsInSlot[slot].at(index);
    }

    function slotCountOfSoul(
        address soul
    ) public view override returns (uint256) {
        return _slotsOfSoul[soul].length();
    }

    function slotOfSoulByIndex(
        address soul,
        uint256 index
    ) public view override returns (uint256) {
        require(
            index < ERC5727SlotEnumerable.slotCountOfSoul(soul),
            "ERC5727SlotEnumerable: soul slot index out of bounds"
        );
        return _slotsOfSoul[soul].at(index);
    }

    function isSoulInSlot(
        address soul,
        uint256 slot
    ) public view virtual override returns (bool) {
        return _soulsInSlot[slot].contains(soul);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727SlotEnumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual override {
        if (!_slotExists(slot)) {
            _allSlots.add(slot);
        }
        _tokensInSlot[slot].add(tokenId);
        if (!_soulsInSlot[slot].contains(soul)) {
            _soulsInSlot[slot].add(soul);
        }
        _slotsOfSoul[soul].add(slot);
    }

    function _addSlot(uint256 slot) internal virtual {
        if (!_slotExists(slot)) {
            _allSlots.add(slot);
        }
    }

    function _beforeTokenDestroy(uint256 tokenId) internal virtual override {
        uint256 slot = _getTokenOrRevert(tokenId).slot;
        _tokensInSlot[slot].remove(tokenId);
        if (_tokensInSlot[slot].length() == 0) {
            _allSlots.remove(slot);
        }
    }

    function slotURI(
        uint256 slot
    ) public view virtual override returns (string memory) {
        require(
            _slotExists(slot),
            "ERC5727SlotEnumerable: slot does not exist"
        );
        return super.slotURI(slot);
    }
}
