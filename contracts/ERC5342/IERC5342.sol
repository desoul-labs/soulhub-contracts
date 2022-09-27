//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev
 */
interface IERC5342 is IERC165 {
    /**
     * @dev Emmited when `tokenId` token is minted to `soul` with `value`.
     */
    event Minted(address indexed soul, uint256 indexed tokenId, uint256 value);

    /**
     * @dev Emmited when `tokenId` token of `soul` is revoked.
     */
    event Revoked(address indexed soul, uint256 indexed tokenId);

    /**
     * @dev Emmited when `value` is charged to `tokenId` token.
     */
    event Charged(uint256 indexed tokenId, uint256 value);

    /**
     * @dev Emmited when `value` of `tokenId` token is consumed.
     */
    event Consumed(uint256 indexed tokenId, uint256 value);

    /**
     * @dev Emmited when `tokenId` token of `soul` is destroyed.
     */
    event Destroyed(address indexed soul, uint256 indexed tokenId);

    /**
     * @dev Emmited when slot of `tokenId` token is changed from `oldSlot` to `newSlot`.
     */
    event SlotChanged(
        uint256 indexed tokenId,
        uint256 indexed oldSlot,
        uint256 indexed newSlot
    );

    /**
     * @dev Returns the value of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function valueOf(uint256 tokenId) external view returns (uint256);

    /**
     * @dev Returns the slot of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function slotOf(uint256 tokenId) external view returns (uint256);

    /**
     * @dev Returns the soul of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function soulOf(uint256 tokenId) external view returns (address);

    /**
     * @dev Returns if `tokenId` token is valid.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function isValid(uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns the issuer of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function issuerOf(uint256 tokenId) external view returns (address);
}
