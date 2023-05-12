//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title ERC5727 Soulbound Token Expirable Interface
 * @dev This extension allows soulbound tokens to be expirable and renewable.
 */
interface IERC5727ExpirableUpgradeable {
    /**
     * @notice Emitted when a subscription expiration changes
     * @dev When a subscription is canceled, the expiration value should also be 0.
     */
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    /**
     * @notice Renews the subscription to an NFT
     * @dev Throws if `tokenId` is not a valid NFT
     * @param tokenId The NFT to renew the subscription for
     * @param duration The number of seconds to extend a subscription for
     */
    function renewSubscription(
        uint256 tokenId,
        uint64 duration
    ) external payable;

    /**
     * @notice Cancels the subscription of an NFT
     * @dev Throws if `tokenId` is not a valid NFT
     * @param tokenId The NFT to cancel the subscription for
     */
    function cancelSubscription(uint256 tokenId) external payable;

    /**
     * @notice Gets the expiration date of a subscription
     * @dev Throws if `tokenId` is not a valid NFT
     * @param tokenId The NFT to get the expiration date of
     * @return The expiration date of the subscription
     */
    function expiresAt(uint256 tokenId) external view returns (uint64);

    /**
     * @notice Determines whether a subscription can be renewed
     * @dev Throws if `tokenId` is not a valid NFT
     * @param tokenId The NFT to get the expiration date of
     * @return The renewability of a the subscription
     */
    function isRenewable(uint256 tokenId) external view returns (bool);

    /**
     * @notice Set the expiry date of a token.
     * @dev MUST revert if the `tokenId` token does not exist.
     *      MUST revert if the `date` is in the past.
     * @param tokenId The token whose expiry date is set
     * @param expiration The expire date to set
     * @param isRenewable Whether the token is renewable
     */
    function setExpiration(
        uint256 tokenId,
        uint64 expiration,
        bool isRenewable
    ) external;
}
