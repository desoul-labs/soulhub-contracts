// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./IERC3526.sol";

interface IERC3526Delegate is IERC3526 {
    /// @notice Grant one-time minting right to `operator` for `owner`
    /// An allowed operator can call the function to transfer rights.
    /// @param operator Address allowed to mint a token
    /// @param owner Address for whom `operator` is allowed to mint a token
    function delegate(address operator, address owner) external;

    /// @notice Grant one-time minting right to a list of `operators` for a corresponding list of `owners`
    /// An allowed operator can call the function to transfer rights.
    /// @param operators Addresses allowed to mint
    /// @param owners Addresses for whom `operators` are allowed to mint a token
    function delegateBatch(address[] memory operators, address[] memory owners)
        external;

    /// @notice Mint a token. Caller must have the right to mint for the owner.
    /// @param owner Address for whom the token is minted
    function mint(
        address owner,
        uint256 value,
        uint256 slot
    ) external;

    /// @notice Mint tokens to multiple addresses. Caller must have the right to mint for all owners.
    /// @param owners Addresses for whom the tokens are minted
    function mintBatch(
        address[] memory owners,
        uint256[] memory values,
        uint256[] memory slots
    ) external;

    /// @notice Get the issuer of a token
    /// @param tokenId Identifier of the token
    /// @return Address who minted `tokenId`
    function issuerOf(uint256 tokenId) external view returns (address);
}
