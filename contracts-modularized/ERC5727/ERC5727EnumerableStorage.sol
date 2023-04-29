// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

library LibERC5727EnumerableStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727Enumerable.storage");

    struct ERC5727EnumerableStorage {
        mapping(address => EnumerableSetUpgradeable.UintSet) _slotsOfOwner;
        mapping(uint256 => EnumerableMapUpgradeable.AddressToUintMap) _ownerBalanceInSlot;
    }

    function s() internal pure returns (ERC5727EnumerableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
