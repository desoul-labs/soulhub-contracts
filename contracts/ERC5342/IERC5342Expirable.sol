//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @dev
 */
interface IERC5342Expirable is IERC5342 {
    /**
     * @dev Returns the expiry date of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function expiryDate(uint256 tokenId) external view returns (uint256);

    /**
     * @dev Returns if `tokenId` token is expired.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function isExpired(uint256 tokenId) external view returns (bool);

    /**
     * @dev Sets expiry `date` of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     * - `date` must in the future.
     */
    function setExpiryDate(uint256 tokenId, uint256 date) external;

    /**
     * @dev Sets expiry `dates` of `tokenIds` tokens.
     *
     * Requirements:
     *
     * - All `tokenIds` tokens must exist.
     * - All `dates` must in the future.
     */
    function setBatchExpiryDates(
        uint256[] memory tokenIds,
        uint256[] memory dates
    ) external;
}
