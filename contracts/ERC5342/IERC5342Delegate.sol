// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Delegate is IERC5342 {
    function mintDelegate(address operator, uint256 delegateRequestId) external;

    function mintDelegateBatch(
        address[] memory operators,
        uint256[] memory delegateRequestIds
    ) external;

    function revokeDelegate(address operator, uint256 tokenId) external;

    function revokeDelegateBatch(
        address[] memory operators,
        uint256[] memory tokenIds
    ) external;

    function delegateMint(uint256 delegateRequestId) external;

    function delegateMintBatch(uint256[] memory delegateRequestIds) external;

    function delegateRevoke(uint256 tokenId) external;

    function delegateRevokeBatch(uint256[] memory tokenIds) external;

    function createDelegateRequest(
        address soul,
        uint256 value,
        uint256 slot
    ) external returns (uint256 delegateRequestId);

    function removeDelegateRequest(uint256 delegateRequestId) external;
}
