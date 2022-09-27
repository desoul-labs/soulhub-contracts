// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

/**
 * @dev
 */
interface IERC5342Consensus is IERC5342 {
    /**
     * @dev Returns the voters.
     */
    function voters() external view returns (address[] memory);

    /**
     * @dev Approves to mint the token described by the `approvalRequestId` to `soul`.
     *
     * Requirement:
     *
     * - The caller must be a voter.
     */
    function approveMint(address soul, uint256 approvalRequestId) external;

    /**
     * @dev Approves to revoke the `tokenId`.
     *
     * Requirement:
     *
     * - The caller must be a voter.
     */
    function approveRevoke(uint256 tokenId) external;

    /**
     * @dev Creates an approval request describing the `value` and `slot` of a token.
     */
    function createApprovalRequest(uint256 value, uint256 slot) external;

    /**
     * @dev Removes `approvalRequestId` approval request.
     *
     * Requirement:
     *
     * - The caller must be the creator of the approval request.
     */
    function removeApprovalRequest(uint256 approvalRequestId) external;

    /**
     * @dev Adds a new voter `newVoter`.
     *
     * Requirement:
     *
     * - The caller must be the administrator.
     * - `newVoter` should not currently be a voter.
     */
    function addVoter(address newVoter) external;

    /**
     * @dev Removes the `voter`.
     *
     * Requirement:
     *
     * - The caller must be the administrator.
     * - `voter` should currently be a voter.
     */
    function removeVoter(address voter) external;
}
