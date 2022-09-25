// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Consensus is IERC5342 {
    function voters() external view returns (address[] memory);

    function approveMint(address owner, uint256 approvalRequestId) external;

    function approveRevoke(uint256 tokenId) external;

    function createApprovalRequest(uint256 value, uint256 slot) external;

    function removeApprovalRequest(uint256 approvalRequestId) external;

    function addVoter(address newVoter) external;

    function removeVoter(address voter) external;
}
