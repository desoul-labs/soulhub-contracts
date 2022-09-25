// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Pull is IERC5342 {
    function pull(address soul, bytes memory signature) external;
}
