// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";

library LibERC5727Storage {
    using AddressUpgradeable for address;
    using StringsUpgradeable for address;
    using StringsUpgradeable for uint256;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727core.storage");

    struct ERC5727Storage {
        /// @dev tokenId => values
        mapping(uint256 => uint256) _values;
        /// @dev tokenId => operators => allowances
        mapping(uint256 => EnumerableMapUpgradeable.AddressToUintMap) _valueApprovals;
        /// @dev tokenId => slot
        mapping(uint256 => uint256) _slots;
        uint8 _decimals;
    }

    function s() internal pure returns (ERC5727Storage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
