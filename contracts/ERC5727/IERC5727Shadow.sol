//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5727.sol";

/**
 * @title
 * @dev
 */
interface IERC5727Shadow is IERC5727 {
    /**
     * @notice Shadow a token.
     * @dev MUST revert if the `tokenId` token does not exists.
     * @param tokenId The token to shadow
     */
    function shadow(uint256 tokenId) external;

    /**
     * @notice Reveal a token.
     * @dev MUST revert if the `tokenId` token does not exists.
     * @param tokenId The token to reveal
     */
    function reveal(uint256 tokenId) external;
}
