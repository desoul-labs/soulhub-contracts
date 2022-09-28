//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";
import "./IERC5342Enumerable.sol";

/**
 * @title
 * @dev
 */
interface IERC5342SlotEnumerable is IERC5342, IERC5342Enumerable {
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
    function tokenInSlotByIndex(uint256 slot, uint256 index)
        external
        view
        returns (uint256);
}
