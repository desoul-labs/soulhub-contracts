// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @title
 * @dev
 */
interface IERC5342Recovery is IERC5342 {
    /**
     * @notice Recover the tokens of `soul` with `signature`.
     * @dev MUST revert if the signature is invalid.
     * @param soul The soul whose tokens are recovered
     * @param signature The signature signed by the `soul`
     */
    function recover(address soul, bytes memory signature) external;
}
