// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727GovernanceUpgradeable.sol";
import "./ERC5727EnumerableUpgradeable.sol";

abstract contract ERC5727GovernanceUpgradeable is
    ERC5727EnumerableUpgradeable,
    IERC5727GovernanceUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 private _approvalRequestCount;

    struct ApprovalRequest {
        address creator;
        uint256 value;
        uint256 slot;
    }

    mapping(uint256 => ApprovalRequest) private _approvalRequests;

    EnumerableSetUpgradeable.AddressSet private _votersArray;

    mapping(address => mapping(uint256 => mapping(address => bool)))
        private _mintApprovals;

    mapping(uint256 => mapping(address => uint256)) private _mintApprovalCounts;

    mapping(address => mapping(uint256 => bool)) private _revokeApprovals;

    mapping(uint256 => uint256) private _revokeApprovalCounts;

    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    function __ERC5727Governance_init_unchained(
        address[] memory voters_
    ) internal onlyInitializing {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        for (uint256 i = 0; i < voters_.length; i++) {
            EnumerableSetUpgradeable.add(_votersArray, voters_[i]);
            _setupRole(VOTER_ROLE, voters_[i]);
        }
    }

    function __ERC5727Governance_init(
        string memory name_,
        string memory symbol_,
        address[] memory voters_
    ) internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        ERC5727Upgradeable.__ERC5727_init_unchained(name_, symbol_);
        __ERC5727Governance_init_unchained(voters_);
    }

    function voters() public view virtual override returns (address[] memory) {
        return EnumerableSetUpgradeable.values(_votersArray);
    }

    function approveMint(
        address soul,
        uint256 approvalRequestId
    ) public virtual override onlyRole(VOTER_ROLE) {
        require(
            !_mintApprovals[_msgSender()][approvalRequestId][soul],
            "ERC5727Governance: You already approved this address"
        );
        _mintApprovals[_msgSender()][approvalRequestId][soul] = true;
        _mintApprovalCounts[approvalRequestId][soul] += 1;
        if (
            _mintApprovalCounts[approvalRequestId][soul] ==
            EnumerableSetUpgradeable.length(_votersArray)
        ) {
            _resetMintApprovals(approvalRequestId, soul);
            _mint(
                _approvalRequests[approvalRequestId].creator,
                soul,
                _approvalRequests[approvalRequestId].value,
                _approvalRequests[approvalRequestId].slot
            );
        }
    }

    function approveRevoke(
        uint256 tokenId
    ) public virtual override onlyRole(VOTER_ROLE) {
        require(
            !_revokeApprovals[_msgSender()][tokenId],
            "ERC5727Governance: You already approved this address"
        );
        _revokeApprovals[_msgSender()][tokenId] = true;
        _revokeApprovalCounts[tokenId] += 1;
        if (
            _revokeApprovalCounts[tokenId] ==
            EnumerableSetUpgradeable.length(_votersArray)
        ) {
            _resetRevokeApprovals(tokenId);
            _revoke(tokenId);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727EnumerableUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727GovernanceUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _resetMintApprovals(
        uint256 approvalRequestId,
        address soul
    ) private {
        for (
            uint256 i = 0;
            i < EnumerableSetUpgradeable.length(_votersArray);
            i++
        ) {
            _mintApprovals[EnumerableSetUpgradeable.at(_votersArray, i)][
                approvalRequestId
            ][soul] = false;
        }
        _mintApprovalCounts[approvalRequestId][soul] = 0;
    }

    function _resetRevokeApprovals(uint256 tokenId) private {
        for (
            uint256 i = 0;
            i < EnumerableSetUpgradeable.length(_votersArray);
            i++
        ) {
            _revokeApprovals[EnumerableSetUpgradeable.at(_votersArray, i)][
                tokenId
            ] = false;
        }
        _revokeApprovalCounts[tokenId] = 0;
    }

    function createApprovalRequest(
        uint256 value,
        uint256 slot
    ) external virtual override {
        require(
            value != 0,
            "ERC5727Governance: Value of Approval Request cannot be 0"
        );
        _approvalRequests[_approvalRequestCount] = ApprovalRequest(
            _msgSender(),
            value,
            slot
        );
        _approvalRequestCount++;
    }

    function removeApprovalRequest(
        uint256 approvalRequestId
    ) external virtual override {
        require(
            _msgSender() == _approvalRequests[approvalRequestId].creator,
            "ERC5727Governance: You are not the creator"
        );
        delete _approvalRequests[approvalRequestId];
    }

    function addVoter(address newVoter) public onlyOwner {
        require(
            !hasRole(VOTER_ROLE, newVoter),
            "ERC5727Governance: newVoter is already a voter"
        );
        EnumerableSetUpgradeable.add(_votersArray, newVoter);
        _setupRole(VOTER_ROLE, newVoter);
    }

    function removeVoter(address voter) public onlyOwner {
        require(
            EnumerableSetUpgradeable.contains(_votersArray, voter),
            "ERC5727Governance: Voter does not exist"
        );
        _revokeRole(VOTER_ROLE, voter);
        EnumerableSetUpgradeable.remove(_votersArray, voter);
    }
}
