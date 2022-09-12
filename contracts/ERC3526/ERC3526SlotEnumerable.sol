// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "./ERC3526.sol";
import "./IERC3526SlotEnumerable.sol";

abstract contract ERC3526SlotEnumerable is
    ERC3526,
    IERC3526SlotEnumerable,
    ERC2771Context
{
    struct SlotData {
        uint256 slot;
        uint256[] slotTokens;
        // mapping(uint256 => uint256) slotTokensIndex;
    }

    // slot => tokenId => index
    mapping(uint256 => mapping(uint256 => uint256)) private _slotTokensIndex;

    SlotData[] private _allSlots;

    // slot => index
    mapping(uint256 => uint256) private _allSlotsIndex;

    function slotCount() public view virtual override returns (uint256) {
        return _allSlots.length;
    }

    function slotByIndex(uint256 index_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index_ < ERC3526SlotEnumerable.slotCount(),
            "ERC3526SlotEnumerable: slot index out of bounds"
        );
        return _allSlots[index_].slot;
    }

    function _slotExists(uint256 slot_) internal view virtual returns (bool) {
        return
            _allSlots.length != 0 &&
            _allSlots[_allSlotsIndex[slot_]].slot == slot_;
    }

    function tokenSupplyInSlot(uint256 slot_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (!_slotExists(slot_)) {
            return 0;
        }
        return _allSlots[_allSlotsIndex[slot_]].slotTokens.length;
    }

    function tokenInSlotByIndex(uint256 slot_, uint256 index_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index_ < ERC3526SlotEnumerable.tokenSupplyInSlot(slot_),
            "ERC3526SlotEnumerable: slot token index out of bounds"
        );
        return _allSlots[_allSlotsIndex[slot_]].slotTokens[index_];
    }

    function _tokenExistsInSlot(uint256 slot_, uint256 tokenId_)
        private
        view
        returns (bool)
    {
        SlotData storage slotData = _allSlots[_allSlotsIndex[slot_]];
        return
            slotData.slotTokens.length > 0 &&
            slotData.slotTokens[_slotTokensIndex[slot_][tokenId_]] == tokenId_;
    }

    function _addSlotToAllSlotsEnumeration(SlotData memory slotData) private {
        _allSlotsIndex[slotData.slot] = _allSlots.length;
        _allSlots.push(slotData);
    }

    function _addTokenToSlotEnumeration(uint256 slot_, uint256 tokenId_)
        private
    {
        SlotData storage slotData = _allSlots[_allSlotsIndex[slot_]];
        _slotTokensIndex[slot_][tokenId_] = slotData.slotTokens.length;
        slotData.slotTokens.push(tokenId_);
    }

    function _removeTokenFromSlotEnumeration(uint256 slot_, uint256 tokenId_)
        private
    {
        SlotData storage slotData = _allSlots[_allSlotsIndex[slot_]];
        uint256 lastTokenIndex = slotData.slotTokens.length - 1;
        uint256 lastTokenId = slotData.slotTokens[lastTokenIndex];
        uint256 tokenIndex = slotData.slotTokens[tokenId_];

        slotData.slotTokens[tokenIndex] = lastTokenId;
        _slotTokensIndex[slot_][lastTokenId] = tokenIndex;

        delete _slotTokensIndex[slot_][tokenId_];
        slotData.slotTokens.pop();
    }
}
