//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";
import "./IERC5342Enumerable.sol";

interface IERC5342SlotEnumerable is IERC5342, IERC5342Enumerable {
    function slotCount() external view returns (uint256);

    function slotByIndex(uint256 index) external view returns (uint256);

    function tokenSupplyInSlot(uint256 slot) external view returns (uint256);

    function tokenInSlotByIndex(uint256 slot, uint256 index)
        external
        view
        returns (uint256);
}
