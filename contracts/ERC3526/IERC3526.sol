//SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title ERC-3526
 */
interface IERC3526 is IERC165 {
    /// Event emitted when a token `tokenId` is minted for `owner` with `value`
    event Minted(address indexed owner, uint256 indexed tokenId, uint256 value);

    /// Event emitted when token `tokenId` of `owner` with `value` is burned
    event Burned(address indexed owner, uint256 indexed tokenId, uint256 value);

    /// Event emitted when token `tokenId` of `owner` is revoked
    event Revoked(address indexed owner, uint256 indexed tokenId);

    /**
     * @dev MUST emit when the slot of a token is set or changed.
     * @param tokenId The token of which slot is set or changed
     * @param oldSlot The previous slot of the token
     * @param newSlot The updated slot of the token
     */
    event SlotChanged(
        uint256 indexed tokenId,
        uint256 indexed oldSlot,
        uint256 indexed newSlot
    );

    /**
     * @notice Get the value of a token.
     * @param tokenId The token for which to query the balance
     * @return The value of `_tokenId`
     */
    function balanceOf(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Get the slot of a token.
     * @param tokenId The identifier for a token
     * @return The slot of the token
     */
    function slotOf(uint256 tokenId) external view returns (uint256);

    /// @notice Count all tokens assigned to an owner
    /// @param owner Address for whom to query the balance
    /// @return Number of tokens owned by `owner`
    function balanceOf(address owner) external view returns (uint256);

    /// @notice Get owner of a token
    /// @param tokenId Identifier of the token
    /// @return Address of the owner of `tokenId`
    function ownerOf(uint256 tokenId) external view returns (address);

    /// @notice Check if a token hasn't been revoked
    /// @param tokenId Identifier of the token
    /// @return True if the token is valid, false otherwise
    function isValid(uint256 tokenId) external view returns (bool);

    /// @notice Check if an address owns a valid token in the contract
    /// @param owner Address for whom to check the ownership
    /// @return True if `owner` has a valid token, false otherwise
    function hasValid(address owner) external view returns (bool);
}
