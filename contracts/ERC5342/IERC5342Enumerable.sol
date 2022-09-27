//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @dev
 */
interface IERC5342Enumerable is IERC5342 {
    /**
     * @dev Returns the total number of tokens emitted.
     */
    function emittedCount() external view returns (uint256);

    /**
     * @dev Returns the total number of souls.
     */
    function soulsCount() external view returns (uint256);

    /**
     * @dev Returns the tokenId of the ``index``-th token of `soul`.
     *
     * Requirements:
     *
     * - `index` must be smaller than the number of tokens owned by `soul`.
     */
    function tokenOfSoulByIndex(address soul, uint256 index)
        external
        view
        returns (uint256);

    /**
     * @dev Returns the tokenId of the token with `index`.
     *
     * Requirements:
     *
     * - `index` must be smaller than the total number of tokens emitted.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);

    /**
     * @dev Returns the number of tokens owned by `soul`.
     *
     * Requirements:
     *
     * - `soul` must own some tokens.
     */
    function balanceOf(address soul) external view returns (uint256);

    /**
     * @dev Returns if the `soul` has valid tokens.
     *
     * Requirements:
     *
     * - `soul` must own some tokens.
     */
    function hasValid(address soul) external view returns (bool);
}
