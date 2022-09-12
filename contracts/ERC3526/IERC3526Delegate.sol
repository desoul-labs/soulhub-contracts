// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "./IERC3526.sol";

interface IERC3526Delegate is IERC3526, ERC2771Context {
    /// @notice Grant one-time minting right to `operator` for `delegateRequestId`
    /// An allowed operator can call the function to transfer rights.
    /// @param operator Address allowed to mint a token
    /// @param delegateRequestId Address for whom `operator` is allowed to mint a token
    function delegate(address operator, uint256 delegateRequestId) external;

    /// @notice Grant one-time minting right to a list of `operators` for a corresponding list of `delegateRequestIds`
    /// An allowed operator can call the function to transfer rights.
    /// @param operators Addresses allowed to mint
    /// @param delegateRequestIds Addresses for whom `operators` are allowed to mint a token
    function delegateBatch(
        address[] memory operators,
        uint256[] memory delegateRequestIds
    ) external;

    /// @notice Mint a token. Caller must have the right to mint for the delegateRequestId.
    /// @param delegateRequestId Address for whom the token is minted
    function mint(uint256 delegateRequestId) external;

    /// @notice Mint tokens to multiple addresses. Caller must have the right to mint for all delegateRequestIds.
    /// @param delegateRequestIds Addresses for whom the tokens are minted
    function mintBatch(uint256[] memory delegateRequestIds) external;

    /// @notice Get the issuer of a token
    /// @param tokenId Identifier of the token
    /// @return Address who minted `tokenId`
    function issuerOf(uint256 tokenId) external view returns (address);

    function createDelegateRequest(
        address delegateRequestId,
        uint256 value,
        uint256 slot
    ) external;

    function removeDelegateRequest(uint256 delegateRequestId) external;
}
