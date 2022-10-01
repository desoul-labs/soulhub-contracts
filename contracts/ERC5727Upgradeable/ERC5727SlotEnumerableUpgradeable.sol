//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./IERC5727SlotEnumerableUpgradeable.sol";

abstract contract ERC5727SlotEnumerableUpgradeable is
    Initializable,
    ERC5727Upgradeable,
    IERC5727SlotEnumerableUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct SlotData {
        uint256 slot;
        EnumerableSetUpgradeable.UintSet slotTokens;
    }

    SlotData[] private _allSlots;

    mapping(uint256 => uint256) private _allSlotsIndex;

    function __ERC5727SlotEnumerable_init_unchained()
        internal
        onlyInitializing
    {}

    function __ERC5727SlotEnumerable_init() internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        __ERC5727SlotEnumerable_init_unchained();
    }

    function slotCount() public view override returns (uint256) {
        return _allSlots.length;
    }

    function slotByIndex(uint256 index) public view override returns (uint256) {
        require(
            index < ERC5727SlotEnumerableUpgradeable.slotCount(),
            "ERC5727SlotEnumerable: slot index out of bounds"
        );
        return _allSlots[index].slot;
    }

    function _slotExists(uint256 slot) internal view virtual returns (bool) {
        return
            _allSlots.length != 0 &&
            _allSlots[_allSlotsIndex[slot]].slot == slot;
    }

    function tokenSupplyInSlot(uint256 slot)
        public
        view
        override
        returns (uint256)
    {
        if (!_slotExists(slot)) {
            return 0;
        }
        return
            EnumerableSetUpgradeable.length(
                _allSlots[_allSlotsIndex[slot]].slotTokens
            );
    }

    function tokenInSlotByIndex(uint256 slot, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(
            index < ERC5727SlotEnumerableUpgradeable.tokenSupplyInSlot(slot),
            "ERC5727SlotEnumerable: slot token index out of bounds"
        );
        return
            EnumerableSetUpgradeable.at(
                _allSlots[_allSlotsIndex[slot]].slotTokens,
                index
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId ==
            type(IERC5727SlotEnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
