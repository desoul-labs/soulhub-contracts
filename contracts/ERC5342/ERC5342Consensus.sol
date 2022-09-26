// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ERC5342.sol";
import "./IERC5342Consensus.sol";
import "./ERC5342Enumerable.sol";

abstract contract ERC5342Consensus is ERC5342Enumerable, IERC5342Consensus {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private _approvalRequestCount;

    struct ApprovalRequest {
        address creator;
        uint256 value;
        uint256 slot;
    }

    mapping(uint256 => ApprovalRequest) private _approvalRequests;

    EnumerableSet.AddressSet private _votersArray;

    mapping(address => mapping(uint256 => mapping(address => bool)))
        private _mintApprovals;

    mapping(uint256 => mapping(address => uint256)) private _mintApprovalCounts;

    mapping(address => mapping(uint256 => bool)) private _revokeApprovals;

    mapping(uint256 => uint256) private _revokeApprovalCounts;

    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory voters_
    ) ERC5342(name_, symbol_) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        for (uint256 i = 0; i < voters_.length; i++) {
            EnumerableSet.add(_votersArray, voters_[i]);
            _setupRole(VOTER_ROLE, voters_[i]);
        }
    }

    function voters() public view virtual override returns (address[] memory) {
        return EnumerableSet.values(_votersArray);
    }

    function approveMint(address soul, uint256 approvalRequestId)
        public
        virtual
        override
        onlyRole(VOTER_ROLE)
    {
        require(
            !_mintApprovals[_msgSender()][approvalRequestId][soul],
            "ERC5342Consensus: You already approved this address"
        );
        _mintApprovals[_msgSender()][approvalRequestId][soul] = true;
        _mintApprovalCounts[approvalRequestId][soul] += 1;
        if (
            _mintApprovalCounts[approvalRequestId][soul] ==
            EnumerableSet.length(_votersArray)
        ) {
            _resetMintApprovals(approvalRequestId, soul);
            _mint(
                soul,
                _approvalRequests[approvalRequestId].value,
                _approvalRequests[approvalRequestId].slot
            );
        }
    }

    function approveRevoke(uint256 tokenId)
        public
        virtual
        override
        onlyRole(VOTER_ROLE)
    {
        require(
            !_revokeApprovals[_msgSender()][tokenId],
            "ERC5342Consensus: You already approved this address"
        );
        _revokeApprovals[_msgSender()][tokenId] = true;
        _revokeApprovalCounts[tokenId] += 1;
        if (
            _revokeApprovalCounts[tokenId] == EnumerableSet.length(_votersArray)
        ) {
            _resetRevokeApprovals(tokenId);
            _revoke(tokenId);
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC5342Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5342Consensus).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _resetMintApprovals(uint256 approvalRequestId, address soul)
        private
    {
        for (uint256 i = 0; i < EnumerableSet.length(_votersArray); i++) {
            _mintApprovals[EnumerableSet.at(_votersArray, i)][
                approvalRequestId
            ][soul] = false;
        }
        _mintApprovalCounts[approvalRequestId][soul] = 0;
    }

    function _resetRevokeApprovals(uint256 tokenId) private {
        for (uint256 i = 0; i < EnumerableSet.length(_votersArray); i++) {
            _revokeApprovals[EnumerableSet.at(_votersArray, i)][
                tokenId
            ] = false;
        }
        _revokeApprovalCounts[tokenId] = 0;
    }

    function createApprovalRequest(uint256 value, uint256 slot)
        external
        virtual
        override
    {
        require(
            value != 0,
            "ERC5342Consensus: Value of Approval Request cannot be 0"
        );
        _approvalRequests[_approvalRequestCount].creator = _msgSender();
        _approvalRequests[_approvalRequestCount].value = value;
        _approvalRequests[_approvalRequestCount].slot = slot;
        _approvalRequestCount++;
    }

    function removeApprovalRequest(uint256 approvalRequestId)
        external
        virtual
        override
    {
        require(
            _msgSender() == _approvalRequests[approvalRequestId].creator,
            "ERC5342Consensus: You are not the creator"
        );
        delete _approvalRequests[approvalRequestId];
    }

    function addVoter(address newVoter) public onlyOwner {
        require(
            !hasRole(VOTER_ROLE, newVoter),
            "ERC5342Consensus: newVoter is already a voter"
        );
        EnumerableSet.add(_votersArray, newVoter);
        _setupRole(VOTER_ROLE, newVoter);
    }

    function removeVoter(address voter) public onlyOwner {
        require(
            EnumerableSet.contains(_votersArray, voter),
            "ERC5342Consensus: Voter does not exist"
        );
        _revokeRole(VOTER_ROLE, voter);
        EnumerableSet.remove(_votersArray, voter);
    }
}
