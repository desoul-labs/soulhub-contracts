//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @dev
 */
interface IERC5342Shadow is IERC5342 {
    /**
     * @dev Shadows the `tokenId` tokens.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function shadow(uint256 tokenId) external;

    /**
     * @dev Reveals the `tokenId` tokens.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function reveal(uint256 tokenId) external;
}
