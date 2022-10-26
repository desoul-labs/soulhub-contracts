//SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./IERC5727.sol";

/**
 *    interfaceId = 0x4ee2cd7e
 */
interface IERC5727Snapshot is IERC5727 {
    event Snapshot(uint256 id);

    function balanceOfAt(address soul, uint256 id)
        external
        view
        returns (uint256);
}
