// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

import "../../ERC173/interfaces/IERC173.sol";
import "./IERC5727Metadata.sol";

/**
 *    interfaceId = 0x0349722d
 */
interface IERC5727Registrant is IERC5727Metadata, IERC173 {
    /**
     * @notice Emitted when the contract is registerd to a registry.
     * @param registry The registry address
     * @param entryId The entry id
     */
    event Registered(address indexed registry, uint256 indexed entryId);

    /**
     * @notice Emitted when a contract is deregistered from a registry.
     * @param registry The registry address
     * @param entryId The entry id
     */
    event Deregistered(address indexed registry, uint256 indexed entryId);

    /**
     * @notice Register the contract to a registry.
     * @dev MUST revert if the contract is already registered.
     * @param registry The registry address
     */
    function register(address registry) external;

    /**
     * @notice Deregister the contract from a registry.
     * @dev MUST revert if the contract is not registered.
     * @param registry The registry address
     */
    function deregister(address registry) external;

    /**
     * @notice Query if the contract is registered to a registry.
     * @param registry The registry address
     * @return True if the contract is registered to the registry
     */
    function isRegistered(address registry) external view returns (bool);
}
