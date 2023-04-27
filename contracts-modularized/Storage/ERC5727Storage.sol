// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "../ERC5484/interfaces/IERC5484Upgradeable.sol";

library LibERC5727Storage {
    using AddressUpgradeable for address;
    using StringsUpgradeable for address;
    using StringsUpgradeable for uint256;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727core.storage");

    struct ERC5727Storage {
        mapping(uint256 => address) _issuers;
        mapping(uint256 => address) _verifiers;
        mapping(uint256 => IERC5484Upgradeable.BurnAuth) _burnAuths;
        mapping(uint256 => bool) _unlocked;
        mapping(uint256 => address) _slotVerifiers;
        mapping(uint256 => IERC5484Upgradeable.BurnAuth) _slotBurnAuths;
        mapping(uint256 => mapping(address => bool)) _minterRole;
        mapping(uint256 => mapping(address => bool)) _burnerRole;
    }

    function s() internal pure returns (ERC5727Storage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
