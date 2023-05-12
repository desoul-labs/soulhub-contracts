//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../../ERC3525/interfaces/IERC3525Upgradeable.sol";
import "../../ERC5192/interfaces/IERC5192Upgradeable.sol";
import "../../ERC5484/interfaces/IERC5484Upgradeable.sol";
import "../../ERC4906/interfaces/IERC4906Upgradeable.sol";

/**
 * @title ERC5727 Soulbound Token Interface
 * @dev The core interface of the ERC5727 standard.
 */
interface IERC5727Upgradeable is
    IERC3525Upgradeable,
    IERC5192Upgradeable,
    IERC5484Upgradeable,
    IERC4906Upgradeable
{
    /**
     * @dev MUST emit when a token is revoked.
     * @param from The address of the owner
     * @param tokenId The token id
     */
    event Revoked(address indexed from, uint256 indexed tokenId);

    /**
     * @dev MUST emit when a token is verified.
     * @param by The address that initiated the verification
     * @param tokenId The token id
     * @param result The result of the verification
     */
    event Verified(address indexed by, uint256 indexed tokenId, bool result);

    /**
     * @notice Get the verifier of a token.
     * @dev MUST revert if the `tokenId` does not exist
     * @param tokenId the token for which to query the verifier
     * @return The address of the verifier of `tokenId`
     */
    function verifierOf(uint256 tokenId) external view returns (address);

    /**
     * @notice Get the issuer of a token.
     * @dev MUST revert if the `tokenId` does not exist
     * @param tokenId the token for which to query the issuer
     * @return The address of the issuer of `tokenId`
     */
    function issuerOf(uint256 tokenId) external view returns (address);

    /**
     * @notice Issue a token in a specified slot with certain value and a verifier to an address.
     * @dev MUST revert if the `to` address is the zero address.
     *      MUST revert if the `verifier` address is the zero address.
     * @param to The address to issue the token to
     * @param tokenId The token id
     * @param slot The slot to issue the token in
     * @param burnAuth The burn authorization of the token
     * @param verifier The address of the verifier
     * @param data Additional data used to issue the token
     */
    function issue(
        address to,
        uint256 tokenId,
        uint256 slot,
        BurnAuth burnAuth,
        address verifier,
        bytes calldata data
    ) external payable;

    /**
     * @notice Issue value to a token.
     * @dev MUST revert if the `tokenId` does not exist.
     * @param tokenId The token id
     * @param amount The amount of the token
     * @param data The additional data used to issue the value
     */
    function issue(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external payable;

    /**
     * @notice Revoke a token from an address.
     * @dev MUST revert if the `tokenId` does not exist.
     * @param tokenId The token id
     * @param data The additional data used to revoke the token
     */
    function revoke(uint256 tokenId, bytes calldata data) external payable;

    /**
     * @notice Revoke value from a token.
     * @dev MUST revert if the `tokenId` does not exist.
     * @param tokenId The token id
     * @param amount The amount of the token
     * @param data The additional data used to revoke the value
     */
    function revoke(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external payable;

    /**
     * @notice Verify a token from an address.
     * @dev MUST revert if the `by` address is the zero address.
     * @param tokenId The token id
     * @param data The additional data used to verify the token
     * @return A boolean indicating whether the token is verified
     */
    function verify(
        uint256 tokenId,
        bytes calldata data
    ) external returns (bool);
}
