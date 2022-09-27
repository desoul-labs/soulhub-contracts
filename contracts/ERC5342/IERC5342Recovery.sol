// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @dev
 */
interface IERC5342Recovery is IERC5342 {
    /**
     * @dev Recovers the tokens of `soul` with `signature`.
     */
    function recover(address soul, bytes memory signature) external;
}
