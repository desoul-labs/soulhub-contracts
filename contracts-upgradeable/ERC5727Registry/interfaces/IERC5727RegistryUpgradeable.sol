// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface IERC5727RegistryUpgradeable is IERC165Upgradeable {
    event Registered(uint256 indexed entry, address indexed addr);

    event Deregistered(uint256 indexed entry, address indexed addr);

    function register(address addr) external returns (uint256);

    function deregister(address addr) external returns (uint256);

    function isRegistered(address addr) external view returns (bool);

    function addressOf(uint256 id) external view returns (address);

    function entryOf(address addr) external view returns (uint256);

    function transferOwnership(address addr, address newOwner) external;

    function registryURI() external view returns (string memory);
}
