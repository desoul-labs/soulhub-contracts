// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./ERC3526.sol";
import "./IERC3526Consensus.sol";

contract ERC3526Consensus is ERC3526, IERC3526Consensus {
    // Number of approval requests
    uint256 private _approvalRequestCount;

    // Approval Request
    struct ApprovalRequest {
        address creator;
        uint256 value;
        uint256 slot;
    }

    // Mapping from approval request ID to approval request
    mapping(uint256 => ApprovalRequest) private _approvalRequests;

    // Consensus voters addresses
    mapping(address => bool) private _voters;
    address[] private _votersArray;

    // Mapping from voter to mint approvals
    mapping(address => mapping(uint256 => mapping(address => bool)))
        private _mintApprovals;

    // Mapping from owner to approval counts
    mapping(uint256 => mapping(address => uint256)) private _mintApprovalCounts;

    // Mapping from voter to revoke approvals
    mapping(address => mapping(uint256 => bool)) private _revokeApprovals;

    // Mapping from tokenId to revoke counts
    mapping(uint256 => uint256) private _revokeApprovalCounts;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address[] memory voters_
    ) ERC3526(name_, symbol_, decimals_) {
        _votersArray = voters_;
        for (uint256 i = 0; i < voters_.length; i++) {
            _voters[voters_[i]] = true;
        }
    }

    /**
     *  @notice Get voters addresses for this consensus contract
     *  @return Addresses of the voters
     */
    function voters() public view virtual override returns (address[] memory) {
        return _votersArray;
    }

    /**
     *  @notice Cast a vote to mint a token for a specific address
     *  @param owner Address for whom to mint the token
     */
    function approveMint(address owner, uint256 approvalRequestId)
        public
        virtual
        override
    {
        require(_voters[_msgSender()], "ERC3526Consensus: You are not a voter");
        require(
            !_mintApprovals[_msgSender()][approvalRequestId][owner],
            "ERC3526Consensus: You already approved this address"
        );
        _mintApprovals[_msgSender()][approvalRequestId][owner] = true;
        _mintApprovalCounts[approvalRequestId][owner] += 1;
        if (
            _mintApprovalCounts[approvalRequestId][owner] == _votersArray.length
        ) {
            _resetMintApprovals(approvalRequestId, owner);
            _mint(
                owner,
                _approvalRequests[approvalRequestId].value,
                _approvalRequests[approvalRequestId].slot
            );
        }
    }

    /**
     *  @notice Cast a vote to revoke a token for a specific address
     *  @param tokenId Identifier of the token to revoke
     */
    function approveRevoke(uint256 tokenId) public virtual override {
        require(_voters[_msgSender()], "ERC3526Consensus: You are not a voter");
        require(
            !_revokeApprovals[_msgSender()][tokenId],
            "ERC3526Consensus: You already approved this address"
        );
        _revokeApprovals[_msgSender()][tokenId] = true;
        _revokeApprovalCounts[tokenId] += 1;
        if (_revokeApprovalCounts[tokenId] == _votersArray.length) {
            _resetRevokeApprovals(tokenId);
            _revoke(tokenId);
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC3526)
        returns (bool)
    {
        return
            interfaceId == type(IERC3526Consensus).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _resetMintApprovals(uint256 approvalRequestId, address owner)
        private
    {
        for (uint256 i = 0; i < _votersArray.length; i++) {
            _mintApprovals[_votersArray[i]][approvalRequestId][owner] = false;
        }
        _mintApprovalCounts[approvalRequestId][owner] = 0;
    }

    function _resetRevokeApprovals(uint256 tokenId) private {
        for (uint256 i = 0; i < _votersArray.length; i++) {
            _revokeApprovals[_votersArray[i]][tokenId] = false;
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
            "ERC3526Consensus: Value of Approval Request cannot be 0"
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
            "ERC3526Consensus: You are not the creator"
        );
        delete _approvalRequests[approvalRequestId];
    }
}
