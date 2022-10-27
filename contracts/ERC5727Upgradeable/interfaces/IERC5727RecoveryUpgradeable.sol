// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./IERC5727Upgradeable.sol";

/**
 * @title ERC5727 Soulbound Token Recovery Interface
 * @dev This extension allows recovering soulbound tokens from an address provided its signature.
 */
interface IERC5727RecoveryUpgradeable is IERC5727Upgradeable {
    /**
     * @notice Recover the tokens of `soul` with `signature`.
     * @dev MUST revert if the signature is invalid.
     * @param soul The soul whose tokens are recovered
     * @param signature The signature signed by the `soul`
     */
    function recover(address soul, bytes memory signature) external;
}
