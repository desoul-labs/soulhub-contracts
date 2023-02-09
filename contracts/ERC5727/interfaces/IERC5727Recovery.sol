// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./IERC5727.sol";

/**
 * @title ERC5727 Soulbound Token Recovery Interface
 * @dev This extension allows recovering soulbound tokens from an address provided its signature.
 */
interface IERC5727Recovery is IERC5727 {
    /**
     * @notice Emitted when the tokens of `owner` are recovered.
     * @param from The owner whose tokens are recovered
     * @param deadline Deadline of timelock of recovery operation
     */
    event Recover(address from, uint256 deadline);

    /**
     * @notice Emitted when the tokens of `owner` are recovered.
     * @param from The owner whose tokens are recovered
     * @param to The new owner of the tokens
     */
    event Recovered(address indexed from, address indexed to);

    /**
     * @notice Emitted when the tokens of `owner` withdraw `Recover` operation.
     * @param from The owner who is planing to recover his tokens
     */
    event RecoveryChallenged(address indexed from);

    /**
     * @notice Recover the tokens of `owner` with `signature`.
     * @dev MUST revert if the signature is invalid.
     * @param owner The owner whose tokens are recovered
     * @param signature The signature signed by the `owner`
     */
    function recover(address owner, bytes memory signature) external;

    /**
     * @notice Ready to recover the tokens of `owner` with `signature` and set a challengeDealine.
     * @dev MUST revert if the signature is invalid.
     * @param owner The owner whose tokens are recovered
     * @param signature The signature signed by the `owner`
     */
    function tryRecover(address owner, bytes memory signature) external;

    /**
     * @notice Withdraw the `Recover` operation
     * @dev MUST revert if the signature is invalid.
     * @dev MUST revert if there is no challenge exists.
     * @param from The owner who is planing to recover his tokens
     */
    function challengeRecovery(address from) external;
}
