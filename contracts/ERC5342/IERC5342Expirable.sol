//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Expirable is IERC5342 {
    function expiryDate(uint256 id) external view returns (uint256);

    function isExpired(uint256 id) external view returns (bool);

    function setExpiryDate(uint256 id, uint256 date) external;

    function setBatchExpiryDates(uint256[] memory ids, uint256[] memory dates)
        external;
}
