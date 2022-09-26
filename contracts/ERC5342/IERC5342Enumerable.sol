//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Enumerable is IERC5342 {
    function emittedCount() external view returns (uint256);

    function soulsCount() external view returns (uint256);

    function tokenOfSoulByIndex(address soul, uint256 index)
        external
        view
        returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function balanceOf(address soul) external view returns (uint256);

    function hasValid(address soul) external view returns (bool);
}
