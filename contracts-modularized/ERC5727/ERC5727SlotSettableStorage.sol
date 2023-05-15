// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../ERC5484/interfaces/IERC5484Upgradeable.sol";

library LibERC5727SlotSettableStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727SlotSettable.storage");

    struct ERC5727SlotSettableStorage {
        mapping(uint256 => uint256) _maxSupply;
        // slot -> period
        mapping(uint256 => uint64) _expiration;
        // slot -> burnAuth
        mapping(uint256 => IERC5484Upgradeable.BurnAuth) _burnAuth;
    }

    function s() internal pure returns (ERC5727SlotSettableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
