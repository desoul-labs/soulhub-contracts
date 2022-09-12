//SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./IERC3526.sol";

/**
 * @title
 * @dev Interfaces for any contract that wants to support enumeration of slots as well as tokens
 *  with the same slot.
 * Note: the ERC-165 identifier for this interface is 0x3b741b9e.
 */
interface IERC3526Enumerable is IERC3526 {
    /// @return emittedCount Number of tokens emitted
    function emittedCount() external view returns (uint256);

    /// @return holdersCount Number of token holders
    function holdersCount() external view returns (uint256);

    /// @notice Get the tokenId of a token using its position in the owner's list
    /// @param owner Address for whom to get the token
    /// @param index Index of the token
    /// @return tokenId of the token
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    /// @notice Get a tokenId by it's index, where 0 <= index < total()
    /// @param index Index of the token
    /// @return tokenId of the token
    function tokenByIndex(uint256 index) external view returns (uint256);
}
