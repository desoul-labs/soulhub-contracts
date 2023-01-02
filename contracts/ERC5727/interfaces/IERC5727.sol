//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../../ERC3525/interfaces/IERC3525.sol";
import "../../ERC5192/interfaces/IERC5192.sol";
import "../../ERC5484/interfaces/IERC5484.sol";

/**
 * @title ERC5727 Soulbound Token Interface
 * @dev The core interface of the ERC5727 standard.
 */
interface IERC5727 is IERC3525, IERC5192, IERC5484 {
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
     * @dev MUST emit when the verifier of a token is changed.
     * @param tokenId The token id
     * @param verifier The address of the new verifier
     */
    event UpdateVerifier(uint256 indexed tokenId, address indexed verifier);

    /**
     * @dev MUST emit when the verifier of a slot is changed.
     * @param slot The slot id
     * @param verifier The address of the new verifier
     */
    event UpdateSlotVerifier(uint256 indexed slot, address indexed verifier);

    /**
     * @notice Set the verifier of a token.
     * @dev MUST revert if the `tokenId` does not exist
     * @param tokenId the token for which to set the verifier
     * @param verifier the address of the verifier
     */
    function setVerifier(uint256 tokenId, address verifier) external;

    /**
     * @notice Set the verifier for all tokens in a slot.
     * @dev MUST revert if the `slot` is not a valid slot.
     * @param slot the slot for which to set the verifier
     * @param verifier the address of the verifier
     */
    function setSlotVerifier(uint256 slot, address verifier) external;

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
     * @param amount The amount of the token
     * @param slot The slot to issue the token in
     * @param burnAuth The burn authorization of the token
     * @param data Additional data used to issue the token
     */
    function issue(
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth burnAuth,
        bytes calldata data
    ) external payable;

    /**
     * @notice Revoke a token from an address.
     * @dev MUST revert if the `from` address is the zero address.
     *      MUST revert if the `from` address is not the owner of the token.
     * @param tokenId The token id
     * @param amount The amount of the token
     * @param data The additional data used to revoke the token
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
