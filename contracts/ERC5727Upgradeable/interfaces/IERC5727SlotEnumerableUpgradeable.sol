//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./IERC5727Upgradeable.sol";
import "./IERC5727EnumerableUpgradeable.sol";

/**
 * @title ERC5727 Soulbound Token Slot Enumerable Interface
 * @dev This extension allows querying information about slots.
 */
interface IERC5727SlotEnumerableUpgradeable is
    IERC5727Upgradeable,
    IERC5727EnumerableUpgradeable
{
    /**
     * @notice Get the total number of slots.
     * @return The total number of slots.
     */
    function slotCount() external view returns (uint256);

    /**
     * @notice Get the slot with `index` among all the slots.
     * @dev MUST revert if the `index` exceed the total number of slots.
     * @param index The index of the slot queried for
     * @return The slot is queried for
     */
    function slotByIndex(uint256 index) external view returns (uint256);

    /**
     * @notice Get the number of tokens in a slot.
     * @dev MUST revert if the slot does not exist.
     * @param slot The slot whose number of tokens is queried for
     * @return The number of tokens in the `slot`
     */
    function tokenSupplyInSlot(uint256 slot) external view returns (uint256);

    /**
     * @notice Get the tokenId with `index` of the `slot`.
     * @dev MUST revert if the `index` exceed the number of tokens in the `slot`.
     * @param slot The slot whose token is queried for.
     * @param index The index of the token queried for
     * @return The token is queried for
     */
    function tokenInSlotByIndex(
        uint256 slot,
        uint256 index
    ) external view returns (uint256);

    /**
     * @notice Get the number of souls in a slot.
     * @dev MUST revert if the slot does not exist.
     * @param slot The slot whose number of souls is queried for
     * @return The number of souls in the `slot`
     */
    function soulsInSlot(uint256 slot) external view returns (uint256);

    /**
     * @notice Check if a soul is in a slot.
     * @dev MUST revert if the slot does not exist.
     * @param soul The soul whose existence in the slot is queried for
     * @param slot The slot whose existence of the soul is queried for
     * @return True if the `soul` is in the `slot`, false otherwise
     */
    function isSoulInSlot(
        address soul,
        uint256 slot
    ) external view returns (bool);

    /**
     * @notice Get the soul with `index` of the `slot`.
     * @dev MUST revert if the `index` exceed the number of souls in the `slot`.
     * @param slot The slot whose soul is queried for.
     * @param index The index of the soul queried for
     * @return The soul is queried for
     */
    function soulInSlotByIndex(
        uint256 slot,
        uint256 index
    ) external view returns (address);

    /**
     * @notice Get the number of slots of a soul.
     * @param soul The soul whose number of slots is queried for
     * @return The number of slots of the `soul`
     */
    function slotCountOfSoul(address soul) external view returns (uint256);

    /**
     * @notice Get the slot with `index` of the `soul`.
     * @dev MUST revert if the `index` exceed the number of slots of the `soul`.
     * @param soul The soul whose slot is queried for.
     * @param index The index of the slot queried for
     * @return The slot is queried for
     */
    function slotOfSoulByIndex(
        address soul,
        uint256 index
    ) external view returns (uint256);
}
