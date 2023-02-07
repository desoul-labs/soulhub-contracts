// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727.sol";
import "./interfaces/IERC5727Governance.sol";

abstract contract ERC5727Governance is IERC5727Governance, ERC5727 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;
    using Strings for uint256;

    modifier onlyVoter() {
        if (!isVoter(_msgSender())) revert MethodNotAllowed(_msgSender());
        _;
    }

    struct IssueApproval {
        address creator;
        address to;
        uint256 tokenId;
        uint256 value;
        uint256 slot;
        uint256 votersApproved;
        ApprovalStatus approvalStatus;
        BurnAuth burnAuth;
    }

    bytes32 public constant VOTER_ROLE = bytes32(uint256(0x03));

    EnumerableSet.AddressSet private _voters;

    Counters.Counter private _approvalRequestCount;
    mapping(uint256 => IssueApproval) private _approvals;

    constructor(
        string memory name_,
        string memory symbol_,
        address admin_,
        address[] memory voters_,
        string memory version_
    ) ERC5727(name_, symbol_, admin_, version_) {
        for (uint256 i = 0; i < voters_.length; ) {
            _voters.add(voters_[i]);
            _setupRole(VOTER_ROLE, voters_[i]);

            unchecked {
                i++;
            }
        }
    }

    function requestApproval(
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth burnAuth,
        bytes calldata data
    ) external virtual override onlyVoter {
        if (to == address(0)) revert NullValue();

        uint256 approvalId = _approvalRequestCount.current();
        _approvals[approvalId] = IssueApproval(
            _msgSender(),
            to,
            tokenId,
            amount,
            slot,
            0,
            ApprovalStatus.Pending,
            burnAuth
        );

        _approvalRequestCount.increment();

        emit ApprovalUpdate(approvalId, _msgSender(), ApprovalStatus.Pending);

        data;
    }

    function removeApprovalRequest(
        uint256 approvalId
    ) external virtual override {
        if (_approvals[approvalId].creator == address(0))
            revert NotFound(approvalId);
        if (_msgSender() != _approvals[approvalId].creator)
            revert Unauthorized(_msgSender());
        if (_approvals[approvalId].approvalStatus != ApprovalStatus.Pending)
            revert Forbidden();

        _approvals[approvalId].approvalStatus = ApprovalStatus.Removed;

        emit ApprovalUpdate(approvalId, address(0), ApprovalStatus.Removed);
    }

    function addVoter(address newVoter) public virtual onlyAdmin {
        if (newVoter == address(0)) revert NullValue();
        if (hasRole(VOTER_ROLE, newVoter))
            revert RoleAlreadyGranted(newVoter, VOTER_ROLE);

        _voters.add(newVoter);
        _setupRole(VOTER_ROLE, newVoter);
    }

    function removeVoter(address voter) public virtual onlyAdmin {
        if (voter == address(0)) revert NullValue();
        if (!_voters.contains(voter)) revert RoleNotGranted(voter, VOTER_ROLE);

        _revokeRole(VOTER_ROLE, voter);
        _voters.remove(voter);
    }

    function voterCount() public view virtual returns (uint256) {
        return _voters.length();
    }

    function voterByIndex(uint256 index) public view virtual returns (address) {
        if (index >= voterCount() || index < 0)
            revert IndexOutOfBounds(index, voterCount());

        return _voters.at(index);
    }

    function isVoter(address voter) public view virtual returns (bool) {
        return hasRole(VOTER_ROLE, voter);
    }

    function voteApproval(
        uint256 approvalId,
        bool approve,
        bytes calldata data
    ) external virtual override onlyVoter {
        if (_approvals[approvalId].creator == address(0))
            revert NotFound(approvalId);

        ApprovalStatus approvalStatus = _approvals[approvalId].approvalStatus;
        if (approvalStatus != ApprovalStatus.Pending) revert Forbidden();

        if (approve) {
            _approvals[approvalId].votersApproved++;
        }
        if (_approvals[approvalId].votersApproved >= voterCount() / 2) {
            _approvals[approvalId].approvalStatus = ApprovalStatus.Approved;
            _issue(
                _msgSender(),
                _approvals[approvalId].to,
                _approvals[approvalId].tokenId,
                _approvals[approvalId].value,
                _approvals[approvalId].slot,
                _approvals[approvalId].burnAuth
            );
        }

        emit ApprovalUpdate(
            approvalId,
            _msgSender(),
            _approvals[approvalId].approvalStatus
        );

        data;
    }

    function approvalURI(
        uint256 approvalId
    ) public view virtual override returns (string memory) {
        if (_approvals[approvalId].creator == address(0))
            revert NotFound(approvalId);

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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Governance).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
