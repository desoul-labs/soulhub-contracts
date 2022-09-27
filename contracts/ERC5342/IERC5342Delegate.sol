// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @dev
 */
interface IERC5342Delegate is IERC5342 {
    /**
     * @dev Delegates a one-time minting right to `operator` for `delegateRequestId` delegate request.
     *
     * Requirement:
     *
     * - The caller must have the right to delegate.
     */
    function mintDelegate(address operator, uint256 delegateRequestId) external;

    /**
     * @dev Delegates a one-time minting right to `operators` for `delegateRequestIds` delegate requests.
     *
     * Requirement:
     *
     * - The caller must have the right to delegate.
     */
    function mintDelegateBatch(
        address[] memory operators,
        uint256[] memory delegateRequestIds
    ) external;

    /**
     * @dev Delegates a one-time revoking right to `operator` for `tokenId` token.
     *
     * Requirement:
     *
     * - The caller must have the right to delegate.
     */
    function revokeDelegate(address operator, uint256 tokenId) external;

    /**
     * @dev Delegates a one-time revoking right to `operators` for `tokenIds` tokens.
     *
     * Requirement:
     *
     * - The caller must have the right to delegate.
     */
    function revokeDelegateBatch(
        address[] memory operators,
        uint256[] memory tokenIds
    ) external;

    /**
     * @dev Mints a token described by `delegateRequestId` delegate request as a delegate.
     *
     * Requirement:
     *
     * - The caller must be delegated and have the right to mint.
     */
    function delegateMint(uint256 delegateRequestId) external;

    /**
     * @dev Mints tokens described by `delegateRequestIds` delegate requests as a delegate.
     *
     * Requirement:
     *
     * - The caller must be delegated and have the right to mint.
     */
    function delegateMintBatch(uint256[] memory delegateRequestIds) external;

    /**
     * @dev Revokes `tokenId` token as a delegate.
     *
     * Requirement:
     *
     * - The caller must be delegated and have the right to revoke.
     */
    function delegateRevoke(uint256 tokenId) external;

    /**
     * @dev Revokes `tokenIds` tokens as a delegate.
     *
     * Requirement:
     *
     * - The caller must be delegated and have the right to revoke.
     */
    function delegateRevokeBatch(uint256[] memory tokenIds) external;

    /**
     * @dev Creates a delegate request describing the `soul`, `value` and `slot` of a token.
     */
    function createDelegateRequest(
        address soul,
        uint256 value,
        uint256 slot
    ) external returns (uint256 delegateRequestId);

    /**
     * @dev Removes `delegateRequestId` delegate request.
     *
     * Requirement:
     *
     * - The caller must be the creator of the delegate request.
     */
    function removeDelegateRequest(uint256 delegateRequestId) external;
}
