//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727ClaimableUpgradeable.sol";

abstract contract ERC5727ClaimableUpgradeable is
    IERC5727ClaimableUpgradeable,
    ERC5727Upgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using MerkleProofUpgradeable for bytes32[];

    // slot => merkelRoot
    mapping(uint256 => bytes32) private _merkelRoots;
    mapping(uint256 => address) private _slotIssuers;

    mapping(address => EnumerableSetUpgradeable.UintSet) private _claimed;

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
            _slotIssuers[slot] != address(0) || _merkelRoots[slot] != bytes32(0)
        ) revert Conflict(slot);

        _slotIssuers[slot] = issuer;
        _merkelRoots[slot] = merkelRoot;
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

        bytes32 merkelRoot = _merkelRoots[slot];
        if (merkelRoot == bytes32(0)) revert NotClaimable();
        if (_claimed[to].contains(slot)) revert AlreadyClaimed();

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

        _issue(_slotIssuers[slot], to, tokenId, slot, burnAuth, verifier);
        _issue(_slotIssuers[slot], tokenId, amount);

        _claimed[to].add(slot);
    }

    function isClaimed(
        address to,
        uint256 slot
    ) public view virtual returns (bool) {
        return _claimed[to].contains(slot);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727ClaimableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
