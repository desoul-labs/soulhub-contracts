//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Shadow is IERC5342 {
    function shadow(uint256 tokenId) external;

    function reveal(uint256 tokenId) external;
}
