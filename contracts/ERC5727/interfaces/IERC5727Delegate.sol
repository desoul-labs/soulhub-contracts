// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "./IERC5727.sol";

/**
 * @title ERC5727 Soulbound Token Delegate Interface
 * @dev This extension allows delegation of issuing and revocation of tokens to an operator.
 */
interface IERC5727Delegate is IERC5727 {
    /**
     * @notice Emitted when a token issuance or revocation is delegated to an operator.
     * @param operator The owner to which the issuing/revoking right is delegated
     * @param tokenId The id of the token to issue/revoke
     */
    event DelegateToken(address indexed operator, uint256 indexed tokenId);

    /**
     * @notice Delegate a one-time isssuing right to `operator` for a token.
     * @dev MUST revert if the caller does not have the right to delegate.
     *      MUST revert if the caller does not have the right to issue.
     *      MUST revert if the `operator` address is the zero address.
     *      MUST revert if the `slot` is not a valid slot.
     * @param operator The owner to which the issuing right is delegated
     * @param to The owner of the token to issue
     * @param tokenId The id of the token to issue
     * @param amount The amount of the token to issue
     * @param slot The slot to issue the token in
     * @param burnAuth The burn authorization of the token
     * @param data The additional data used to issue the tokens
     */
    function delegateIssue(
        address operator,
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth burnAuth,
        bytes calldata data
    ) external;

    /**
     * @notice Delegate a one-time revoking right to `operator` for a token.
     * @dev MUST revert if the caller does not have the right to delegate.
     *      MUST revert if the caller does not have the right to revoke.
     *      MUST revert if the `operator` address is the zero address.
     * @param operator The owner to which the revoking right is delegated
     * @param tokenId The id of the token to revoke
     * @param amount The amount of the token to revoke
     * @param data The additional data used to revoke the tokens
     */
    function delegateRevoke(
        address operator,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external;
}
