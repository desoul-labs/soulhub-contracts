// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ERC5727.sol";
import "./interfaces/IERC5727Governance.sol";

abstract contract ERC5727Governance is IERC5727Governance, ERC5727 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _approvalRequestCount;

    struct IssueApproval {
        address to;
        address tokenId;
        uint256 value;
        uint256 slot;
        BurnAuth burnAuth;
    }

    struct RevokeApproval {
        address tokenId;
        uint256 value;
    }

    EnumerableSet.UintSet private _allApprovals;
    mapping(uint256 => IssueApproval) private _issueApprovals;
    mapping(uint256 => RevokeApproval) private _revokeApprovals;

    mapping(uint256 => address) private _approvalCreators;

    EnumerableSet.AddressSet private _votersArray;

    bytes32 public constant VOTER_ROLE = bytes32(uint256(0x02));

    constructor(
        string memory name_,
        string memory symbol_,
        address admin_,
        address[] memory voters_
    ) ERC5727(name_, symbol_, admin_) {
        for (uint256 i = 0; i < voters_.length; ) {
            _votersArray.add(voters_[i]);
            _setupRole(VOTER_ROLE, voters_[i]);

            unchecked {
                i++;
            }
        }
    }

    function voterCount() public view virtual override returns (uint256) {
        return _votersArray.length();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Governance).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function removeApprovalRequest(
        uint256 approvalId
    ) external virtual override {
        if (_msgSender() != _approvalCreators[approvalId])
            revert Unauthorized(_msgSender());

        _allApprovals.remove(approvalId);
        delete _issueApprovals[approvalId];
        delete _revokeApprovals[approvalId];
        delete _approvalCreators[approvalId];

        emit ApprovalUpdate(approvalId, address(0), ApprovalStatus.Removed);
    }

    function addVoter(address newVoter) public onlyAdmin {
        if (newVoter == address(0)) revert NullValue();
        require(
            !hasRole(VOTER_ROLE, newVoter),
            "ERC5727Governance: newVoter is already a voter"
        );
        _votersArray.add(newVoter);
        _setupRole(VOTER_ROLE, newVoter);

        emit VoterAdded(newVoter);
    }

    function removeVoter(address voter) public onlyAdmin {
        if (voter == address(0)) revert NullValue();
        require(
            _votersArray.contains(voter),
            "ERC5727Governance: Voter does not exist"
        );
        _revokeRole(VOTER_ROLE, voter);
        _votersArray.remove(voter);

        emit VoterRemoved(voter);
    }
}
