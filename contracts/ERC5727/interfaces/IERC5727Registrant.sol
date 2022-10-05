// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC5727Registrant {
    event Registered(address indexed registry);

    event Deregistered(address indexed registry);

    function register(address registry) external returns (uint256);

    function deregister(address registry) external returns (uint256);

    function isRegistered(address registry) external view returns (bool);
}
