// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC3526.sol";

/**
 * @dev Interface for ERC3526 tokens with an expiry date.
 * The dates are stored as unix timestamps in seconds.
 */
interface IERC3526Expirable is IERC3526 {
    /**
     * @dev Returns the expiry date for tokens with a given `id`.
     */
    function expiryDate(uint256 id) external view returns (uint256);

    /**
     * @dev Returns whether tokens are expired by comparing their expiry date with `block.timestamp`.
     */
    function isExpired(uint256 id) external view returns (bool);

    /**
     * @dev Sets the expiry date for the tokens with id `id`.
     */
    function setExpiryDate(uint256 id, uint256 date) external;

    /**
     * @dev [Batched] version of {setExpiryDate}.
     */
    function setBatchExpiryDates(uint256[] memory ids, uint256[] memory dates)
        external;
}
