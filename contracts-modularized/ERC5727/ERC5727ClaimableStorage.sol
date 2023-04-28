// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

library LibERC5727ClaimableStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using MerkleProofUpgradeable for bytes32[];

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727Claimable.storage");

    struct ERC5727ClaimableStorage {
        // slot => merkelRoot
        mapping(uint256 => bytes32) _merkelRoots;
        mapping(uint256 => address) _slotIssuers;
        mapping(address => EnumerableSetUpgradeable.UintSet) _claimed;
    }

    function s() internal pure returns (ERC5727ClaimableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
