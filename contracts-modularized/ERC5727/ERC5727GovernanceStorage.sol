// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "../ERC5484/interfaces/IERC5484Upgradeable.sol";
import "./interfaces/IERC5727GovernanceUpgradeable.sol";

library LibERC5727GovernanceStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    enum ApprovalStatus {
        Pending,
        Approved,
        Rejected,
        Removed
    }

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc5727Governance.storage");

    struct ERC5727GovernanceStorage {
        mapping(address => bool) _voterRole;
        EnumerableSetUpgradeable.AddressSet _voters;
        CountersUpgradeable.Counter _approvalRequestCount;
        mapping(uint256 => IERC5727GovernanceUpgradeable.IssueApproval) _approvals;
    }

    function s() internal pure returns (ERC5727GovernanceStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
