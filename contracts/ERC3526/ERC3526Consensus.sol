// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./ERC3526.sol";
import "./IERC3526Consensus.sol";

abstract contract ERC3526Consensus is ERC3526, IERC3526Consensus {
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

    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory voters_
    ) ERC3526(name_, symbol_) {
        _votersArray = voters_;
        for (uint256 i = 0; i < voters_.length; i++) {
            _setupRole(VOTER_ROLE, voters_[i]);
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
        onlyRole(VOTER_ROLE)
    {
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
    function approveRevoke(uint256 tokenId)
        public
        virtual
        override
        onlyRole(VOTER_ROLE)
    {
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

    function addVoter(address newVoter) public onlyOwner {
        require(
            !hasRole(VOTER_ROLE, newVoter),
            "ERC3526Consensus: newVoter is already a voter"
        );
        _votersArray[_votersArray.length] = newVoter;
        _setupRole(VOTER_ROLE, newVoter);
    }

    function removeVoter(uint256 index) public onlyOwner {
        require(
            index < _votersArray.length,
            "ERC3526Consensus: Index overflow"
        );
        _revokeRole(VOTER_ROLE, _votersArray[index]);
        _removeFromUnorderedArray(_votersArray, index);
    }

    function _removeFromUnorderedArray(address[] storage array, uint256 index)
        internal
    {
        require(index < array.length, "ERC3526Consensus: Index overflow");
        if (index != array.length - 1) {
            array[index] = array[array.length - 1];
        }
        array.pop();
    }
}
