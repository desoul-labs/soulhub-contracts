//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./IERC5727.sol";
import "../../ERC5496/interfaces/IERC5496.sol";

/**
 * @title ERC5727 Soulbound Token Privilege Interface
 * @dev This extension allows soulbound tokens to be expirable and renewable.
 */
interface IERC5727Privilege is IERC5727, IERC5496 {
    /**
     * @notice The URI of the privilege.
     * @dev MUST revert if the `privilegeId` does not exist.
     * @param privilegeId The privilege ID
     * @return The URI of the privilege
     */
    function privilegeURI(
        uint256 privilegeId
    ) external view returns (string memory);
}
