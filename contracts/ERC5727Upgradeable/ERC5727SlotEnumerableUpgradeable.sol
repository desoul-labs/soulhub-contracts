//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727SlotEnumerableUpgradeable.sol";

abstract contract ERC5727SlotEnumerableUpgradeable is
    Initializable,
    ERC5727Upgradeable,
    IERC5727SlotEnumerableUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping(uint256 => EnumerableSetUpgradeable.UintSet) private _tokensInSlot;

    EnumerableSetUpgradeable.UintSet private _allSlots;

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
        return _allSlots.length();
    }

    function slotByIndex(uint256 index) public view override returns (uint256) {
        require(
            index < ERC5727SlotEnumerableUpgradeable.slotCount(),
            "ERC5727SlotEnumerable: slot index out of bounds"
        );
        return _allSlots.at(index);
    }

    function _slotExists(uint256 slot) internal view virtual returns (bool) {
        return _allSlots.length() != 0 && _allSlots.contains(slot);
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
        return _tokensInSlot[slot].length();
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
        return _tokensInSlot[slot].at(index);
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
        //unused
        issuer;
        soul;
        value;
        valid;
    }

    function _beforeTokenDestroy(uint256 tokenId) internal virtual override {
        uint256 slot = _getTokenOrRevert(tokenId).slot;
        _tokensInSlot[slot].remove(tokenId);
        if (_tokensInSlot[slot].length() == 0) {
            _allSlots.remove(slot);
        }
    }
}
