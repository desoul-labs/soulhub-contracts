// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC5727ExpirableStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727Expirable.storage");

    struct ERC5727ExpirableStorage {
        mapping(uint256 => uint64) _expiryDate;
        mapping(uint256 => bool) _isRenewable;
        mapping(uint256 => uint64) _slotExpiryDate;
        mapping(uint256 => bool) _slotIsRenewable;
    }

    function s() internal pure returns (ERC5727ExpirableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
