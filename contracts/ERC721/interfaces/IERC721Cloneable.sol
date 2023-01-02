// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IERC721Cloneable {
    /// @notice Emitted when set the `privilege ` of a NFT cloneable.
    event PrivilegeCloned(
        uint tokenId,
        uint privilegeId,
        address from,
        address to
    );

    /// @notice set a certain privilege cloneable
    /// @param tokenId The identifier of the queried NFT
    /// @param privilegeId The identifier of the queried privilege
    /// @param referrer The address of the referrer
    /// @return Whether the operation is successful or not
    function clonePrivilege(
        uint tokenId,
        uint privilegeId,
        address referrer
    ) external returns (bool);
}
