// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727GovernanceUpgradeable.sol";

abstract contract ERC5727GovernanceUpgradeable is
    IERC5727GovernanceUpgradeable,
    ERC5727Upgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    modifier onlyVoter() {
        if (!isVoter(_msgSender())) revert MethodNotAllowed(_msgSender());
        _;
    }

    struct IssueApproval {
        address creator;
        address to;
        uint256 tokenId;
        uint256 amount;
        uint256 slot;
        uint256 votersApproved;
        uint256 votersRejected;
        ApprovalStatus approvalStatus;
        BurnAuth burnAuth;
        address verifier;
    }

    bytes32 public constant VOTER_ROLE = bytes32(uint256(0x04));

    EnumerableSetUpgradeable.AddressSet private _voters;

    CountersUpgradeable.Counter private _approvalRequestCount;
    mapping(uint256 => IssueApproval) private _approvals;

    function __ERC5727Governance_init(
        string memory name_,
        string memory symbol_,
        address admin_,
        address[] memory voters_,
        string memory version_
    ) internal onlyInitializing {
        __EIP712_init_unchained(name_, version_);
        __ERC721_init_unchained(name_, symbol_);
        __ERC3525_init_unchained(18);
        __ERC5727_init_unchained(admin_);
        __ERC5727Governance_init_unchained(voters_);
    }

    function __ERC5727Governance_init_unchained(
        address[] memory voters_
    ) internal onlyInitializing {
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
        address verifier,
        bytes calldata data
    ) external virtual override onlyVoter {
        if (to == address(0) || tokenId == 0 || slot == 0) revert NullValue();

        uint256 approvalId = _approvalRequestCount.current();
        _approvals[approvalId] = IssueApproval(
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
        if (index >= voterCount()) revert IndexOutOfBounds(index, voterCount());

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
        IssueApproval storage approval = _approvals[approvalId];
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
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727GovernanceUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
