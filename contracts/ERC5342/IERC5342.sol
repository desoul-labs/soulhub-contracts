//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC5342 is IERC165 {
    event Minted(address indexed soul, uint256 indexed tokenId, uint256 value);
    event Revoked(address indexed soul, uint256 indexed tokenId);
    event Charged(uint256 indexed tokenId, uint256 value);
    event Consumed(uint256 indexed tokenId, uint256 value);
    event Destroyed(address indexed soul, uint256 indexed tokenId);
    event SlotChanged(
        uint256 indexed tokenId,
        uint256 indexed oldSlot,
        uint256 indexed newSlot
    );

    function valueOf(uint256 tokenId) external view returns (uint256);

    function slotOf(uint256 tokenId) external view returns (uint256);

    function soulOf(uint256 tokenId) external view returns (address);

    function isValid(uint256 tokenId) external view returns (bool);

    function issuerOf(uint256 tokenId) external view returns (address);

    function balanceOf(address soul) external view returns (uint256);

    function hasValid(address soul) external view returns (bool);
}
