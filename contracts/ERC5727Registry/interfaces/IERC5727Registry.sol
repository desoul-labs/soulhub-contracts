// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC5727Registry is IERC165 {
    event Registered(uint256 indexed id, address indexed addr);

    event Deregistered(uint256 indexed id, address indexed addr);

    function register(address addr) external returns (uint256);

    function deregister(address addr) external returns (uint256);

    function isRegistered(address addr) external view returns (bool);

    function addressOf(uint256 id) external view returns (address);

    function idOf(address addr) external view returns (uint256);

    function total() external view returns (uint256);
}
