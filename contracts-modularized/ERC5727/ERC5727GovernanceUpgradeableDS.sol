// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727Core.sol";
import "./interfaces/IERC5727GovernanceUpgradeable.sol";
import "./ERC5727GovernanceStorage.sol";

contract ERC5727GovernanceUpgradeableDS is
    IERC5727GovernanceUpgradeable,
    ERC5727Core
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    modifier onlyVoter() {
        if (!isVoter(_msgSender())) revert MethodNotAllowed(_msgSender());
        _;
    }

    function __ERC5727Governance_init_unchained(
        address admin_
    ) internal onlyInitializing {
        LibERC5727GovernanceStorage.s()._voters.add(admin_);
        LibERC5727GovernanceStorage.s()._voterRole[admin_] = true;
    }

    function requestApproval(
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        IERC5484Upgradeable.BurnAuth burnAuth,
        address verifier,
        bytes calldata data
    ) external virtual override onlyVoter {
        if (to == address(0) || tokenId == 0 || slot == 0) revert NullValue();

        uint256 approvalId = LibERC5727GovernanceStorage
            .s()
            ._approvalRequestCount
            .current();
        LibERC5727GovernanceStorage.s()._approvals[approvalId] = IssueApproval(
            _msgSender(),
            to,
            tokenId,
            amount,
            slot,
            0,
            0,
            ApprovalStatus.Pending,
            burnAuth,
            verifier
        );

        LibERC5727GovernanceStorage.s()._approvalRequestCount.increment();

        emit ApprovalUpdate(approvalId, _msgSender(), ApprovalStatus.Pending);

        data;
    }

    function removeApprovalRequest(
        uint256 approvalId
    ) external virtual override {
        if (
            LibERC5727GovernanceStorage.s()._approvals[approvalId].creator ==
            address(0)
        ) revert NotFound(approvalId);
        if (
            _msgSender() !=
            LibERC5727GovernanceStorage.s()._approvals[approvalId].creator
        ) revert Unauthorized(_msgSender());
        if (
            LibERC5727GovernanceStorage
                .s()
                ._approvals[approvalId]
                .approvalStatus != ApprovalStatus.Pending
        ) revert Forbidden();

        LibERC5727GovernanceStorage
            .s()
            ._approvals[approvalId]
            .approvalStatus = ApprovalStatus.Removed;

        emit ApprovalUpdate(approvalId, address(0), ApprovalStatus.Removed);
    }

    function addVoter(address newVoter) public virtual onlyAdmin {
        if (newVoter == address(0)) revert NullValue();
        if (LibERC5727GovernanceStorage.s()._voterRole[newVoter])
            revert RoleAlreadyGranted(newVoter, "voter");

        LibERC5727GovernanceStorage.s()._voters.add(newVoter);
        LibERC5727GovernanceStorage.s()._voterRole[newVoter] = true;
    }

    function removeVoter(address voter) public virtual onlyAdmin {
        if (voter == address(0)) revert NullValue();
        if (!LibERC5727GovernanceStorage.s()._voters.contains(voter))
            revert RoleNotGranted(voter, "voter");

        LibERC5727GovernanceStorage.s()._voterRole[voter] = false;
        LibERC5727GovernanceStorage.s()._voters.remove(voter);
    }

    function voterCount() public view virtual returns (uint256) {
        return LibERC5727GovernanceStorage.s()._voters.length();
    }

    function voterByIndex(uint256 index) public view virtual returns (address) {
        if (index >= voterCount()) revert IndexOutOfBounds(index, voterCount());

        return LibERC5727GovernanceStorage.s()._voters.at(index);
    }

    function isVoter(address voter) public view virtual returns (bool) {
        return LibERC5727GovernanceStorage.s()._voterRole[voter];
    }

    function voteApproval(
        uint256 approvalId,
        bool approve,
        bytes calldata data
    ) external virtual override onlyVoter {
        IssueApproval storage approval = LibERC5727GovernanceStorage
            .s()
            ._approvals[approvalId];
        if (approval.creator == address(0)) revert NotFound(approvalId);

        ApprovalStatus approvalStatus = approval.approvalStatus;
        if (approvalStatus != ApprovalStatus.Pending) revert Forbidden();

        if (approve) {
            approval.votersApproved++;
        } else {
            approval.votersRejected++;
        }

        if (approval.votersApproved > voterCount() / 2) {
            approval.approvalStatus = ApprovalStatus.Approved;
            _issue(
                _msgSender(),
                approval.to,
                approval.tokenId,
                approval.slot,
                approval.burnAuth,
                approval.verifier
            );
            _issue(_msgSender(), approval.tokenId, approval.amount);

            emit ApprovalUpdate(
                approvalId,
                _msgSender(),
                ApprovalStatus.Approved
            );
        }
        if (approval.votersRejected > voterCount() / 2) {
            approval.approvalStatus = ApprovalStatus.Rejected;

            emit ApprovalUpdate(
                approvalId,
                _msgSender(),
                ApprovalStatus.Rejected
            );
        }

        data;
    }

    function getApproval(
        uint256 approvalId
    ) public view virtual returns (IssueApproval memory) {
        if (
            LibERC5727GovernanceStorage.s()._approvals[approvalId].creator ==
            address(0)
        ) revert NotFound(approvalId);

        return LibERC5727GovernanceStorage.s()._approvals[approvalId];
    }

    function approvalURI(
        uint256 approvalId
    ) public view virtual override returns (string memory) {
        if (
            LibERC5727GovernanceStorage.s()._approvals[approvalId].creator ==
            address(0)
        ) revert NotFound(approvalId);

        string memory contractUri = contractURI();
        return
            bytes(contractUri).length > 0
                ? string(
                    abi.encodePacked(
                        contractUri,
                        "/approvals/",
                        approvalId.toString()
                    )
                )
                : "";
    }
}
