//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727ClaimableUpgradeable.sol";
import "./ERC5727ClaimableStorage.sol";

abstract contract ERC5727ClaimableUpgradeable is
    IERC5727ClaimableUpgradeable,
    ERC5727UpgradeableDS
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using MerkleProofUpgradeable for bytes32[];

    function __ERC5727Claimable_init() internal onlyInitializing {
        __ERC5727Claimable_init_unchained();
    }

    function __ERC5727Claimable_init_unchained() internal onlyInitializing {}

    function setClaimEvent(
        address issuer,
        uint256 slot,
        bytes32 merkelRoot
    ) external virtual onlyAdmin {
        if (
            LibERC5727ClaimableStorage.s()._slotIssuers[slot] != address(0) ||
            LibERC5727ClaimableStorage.s()._merkelRoots[slot] != bytes32(0)
        ) revert Conflict(slot);

        LibERC5727ClaimableStorage.s()._slotIssuers[slot] = issuer;
        LibERC5727ClaimableStorage.s()._merkelRoots[slot] = merkelRoot;
    }

    function claim(
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth burnAuth,
        address verifier,
        bytes calldata data,
        bytes32[] calldata proof
    ) external virtual override {
        if (to == address(0) || tokenId == 0 || slot == 0) revert NullValue();
        if (to != _msgSender()) revert Unauthorized(_msgSender());

        bytes32 merkelRoot = LibERC5727ClaimableStorage.s()._merkelRoots[slot];
        if (merkelRoot == bytes32(0)) revert NotClaimable();
        if (LibERC5727ClaimableStorage.s()._claimed[to].contains(slot))
            revert AlreadyClaimed();

        bytes32 node = keccak256(
            abi.encodePacked(
                to,
                tokenId,
                amount,
                slot,
                burnAuth,
                verifier,
                data
            )
        );
        if (!proof.verifyCalldata(merkelRoot, node)) revert Unauthorized(to);

        _issue(
            LibERC5727ClaimableStorage.s()._slotIssuers[slot],
            to,
            tokenId,
            slot,
            burnAuth,
            verifier
        );
        _issue(
            LibERC5727ClaimableStorage.s()._slotIssuers[slot],
            tokenId,
            amount
        );

        LibERC5727ClaimableStorage.s()._claimed[to].add(slot);
    }

    function isClaimed(
        address to,
        uint256 slot
    ) public view virtual returns (bool) {
        return LibERC5727ClaimableStorage.s()._claimed[to].contains(slot);
    }
}
