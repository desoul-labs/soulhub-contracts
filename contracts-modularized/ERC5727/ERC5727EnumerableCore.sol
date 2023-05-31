//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727Core.sol";
import "./interfaces/IERC5727EnumerableUpgradeable.sol";
import "../ERC3525/ERC3525SlotEnumerableCore.sol";
import "./ERC5727EnumerableStorage.sol";

contract ERC5727EnumerableCore is ERC5727Core, ERC3525SlotEnumerableCore {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    function slotCountOfOwner(address owner) internal view returns (uint256) {
        if (owner == address(0)) revert NullValue();

        return LibERC5727EnumerableStorage.s()._slotsOfOwner[owner].length();
    }

    function slotOfOwnerByIndex(
        address owner,
        uint256 index
    ) internal view returns (uint256) {
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
    ) internal view returns (uint256) {
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
    ) internal virtual override(ERC721EnumerableCore, ERC5727Core) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC3525Core, ERC5727Core) {
        ERC5727Core._burn(tokenId);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override(ERC3525SlotEnumerableCore, ERC5727Core) {
        ERC3525SlotEnumerableCore._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );

        ERC5727Core._beforeValueTransfer(
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
    ) internal virtual override(ERC3525SlotEnumerableCore, ERC3525Core) {
        ERC3525SlotEnumerableCore._afterValueTransfer(
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
