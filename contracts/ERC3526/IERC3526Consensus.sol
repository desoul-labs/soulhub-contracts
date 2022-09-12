// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "./IERC3526.sol";

interface IERC3526Consensus is IERC3526, ERC2771Context {
    /**
     * @notice Get voters addresses for this consensus contract
     * @return Addresses of the voters
     */
    function voters() external view returns (address[] memory);

    /// @notice Cast a vote to mint a token for a specific address
    /// @param owner Address for whom to mint the token
    function approveMint(address owner, uint256 approvalRequestId) external;

    /// @notice Cast a vote to revoke a specific token
    /// @param tokenId Identifier of the token to revoke
    function approveRevoke(uint256 tokenId) external;

    function createApprovalRequest(uint256 value, uint256 slot) external;

    function removeApprovalRequest(uint256 approvalRequestId) external;
}
