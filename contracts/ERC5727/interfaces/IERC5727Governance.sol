// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./IERC5727.sol";

/**
 * @title ERC5727 Soulbound Token Governance Interface
 * @dev This extension allows issuing of tokens by community voting.
 */
interface IERC5727Governance is IERC5727 {
    enum ApprovalStatus {
        Pending,
        Approved,
        Rejected,
        Removed
    }

    /**
     * @notice Emitted when a token issuance approval is changed.
     * @param approvalId The id of the approval
     * @param creator The creator of the approval, zero address if the approval is removed
     */
    event ApprovalUpdate(
        uint256 indexed approvalId,
        address indexed creator,
        ApprovalStatus status
    );

    /**
     * @notice Emitted when a voter approves an approval.
     * @param voter The voter who approves the approval
     * @param approvalId The id of the approval
     */
    event Approve(address indexed voter, uint256 indexed approvalId);

    /**
     * @notice Emitted when a voter rejects an approval.
     * @param voter The voter who rejects the approval
     * @param approvalId The id of the approval
     */
    event Reject(address indexed voter, uint256 indexed approvalId);

    /**
     * @notice Emitted when a voter is added to the contract.
     * @param voter The voter to add
     */
    event VoterAdded(address indexed voter);

    /**
     * @notice Emitted when a voter is removed from the contract.
     * @param voter The voter to remove
     */
    event VoterRemoved(address indexed voter);

    /**
     * @notice return the number of voters.
     */
    function voterCount() external view returns (uint256);

    /**
     * @notice return the voter at `index`.
     * @param index the index of the voter
     */
    function voterByIndex(uint256 index) external view returns (address);

    /**
     * @notice return if the `voter` is a voter.
     * @param voter the voter to check
     * @return true if the `voter` is a voter, false otherwise
     */
    function isVoter(address voter) external view returns (bool);

    /**
     * @notice Add a new voter `newVoter`.
     * @dev MUST revert if the caller is not an administrator.
     *  MUST revert if `newVoter` is already a voter.
     * @param voter the new voter to add
     */
    function addVoter(address voter) external;

    /**
     * @notice Remove the `voter` from the contract.
     * @dev MUST revert if the caller is not an administrator.
     *  MUST revert if `voter` is not a voter.
     * @param voter the voter to remove
     */
    function removeVoter(address voter) external;

    /**
     * @notice Create an approval of issuing a token.
     * @dev MUST revert if the caller is not a voter.
     *      MUST revert if the `to` address is the zero address.
     * @param to The owner which the token to mint to
     * @param tokenId The id of the token to mint
     * @param amount The amount of the token to mint
     * @param slot The slot of the token to mint
     * @param burnAuth The burn authorization of the token to mint
     * @param data The additional data used to mint the token
     */
    function requestApproval(
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth burnAuth,
        bytes calldata data
    ) external;

    /**
     * @notice Remove `approvalId` approval request.
     * @dev MUST revert if the caller is not the creator of the approval request.
     *      MUST revert if the approval request is already approved or rejected or non-existent.
     * @param approvalId The approval to remove
     */
    function removeApprovalRequest(uint256 approvalId) external;

    /**
     * @notice Approve `approvalId` approval request.
     * @dev MUST revert if the caller is not a voter.
     *     MUST revert if the approval request is already approved or rejected or non-existent.
     * @param approvalId The approval to approve
     */
    function approve(uint256 approvalId) external;

    /**
     * @notice Reject `approvalId` approval request.
     * @dev MUST revert if the caller is not a voter.
     *     MUST revert if the approval request is already approved or rejected or non-existent.
     * @param approvalId The approval to reject
     */
    function reject(uint256 approvalId) external;

    /**
     * @notice Get the URI of the approval.
     * @dev MUST revert if the `approvalId` does not exist.
     * @param approvalId The approval whose URI is queried for
     * @return The URI of the approval
     */
    function approvalURI(
        uint256 approvalId
    ) external view returns (string memory);
}
