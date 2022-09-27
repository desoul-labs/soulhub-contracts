//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5342.sol";

interface IERC5342Metadata is IERC5342 {
    /**
     * @dev Returns the name of the contract.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the contract.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns URI of `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Returns the URI of the contract.
     */
    function contractURI() external view returns (string memory);

    /**
     * @dev Returns the URI of `slot`.
     *
     * Requirements:
     *
     * - `slot` must exist.
     */
    function slotURI(uint256 slot) external view returns (string memory);
}
