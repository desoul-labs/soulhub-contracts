//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";
import "./IERC5342Enumerable.sol";

/**
 * @dev
 */
interface IERC5342SlotEnumerable is IERC5342, IERC5342Enumerable {
    /**
     * @dev Returns the total number of slots.
     */
    function slotCount() external view returns (uint256);

    /**
     * @dev Returns the slot with `index`.
     *
     * Requirements:
     *
     * - `index` must smaller than the total number of slots.
     */
    function slotByIndex(uint256 index) external view returns (uint256);

    /**
     * @dev Returns number of tokens in `slot`.
     *
     * Requirements:
     *
     * - `slot` must exist.
     */
    function tokenSupplyInSlot(uint256 slot) external view returns (uint256);

    /**
     * @dev Returns the token in `slot` with `index`.
     *
     * Requirements:
     *
     * - `slot` must exist and `index` must be smaller than the number of tokens in `slot`.
     */
    function tokenInSlotByIndex(uint256 slot, uint256 index)
        external
        view
        returns (uint256);
}
