// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./ERC3526.sol";
import "./IERC3526Consensus.sol";

contract ERC3526Consensus is ERC3526, IERC3526Consensus {
    // Consensus voters addresses
    mapping(address => bool) private _voters;
    address[] private _votersArray;

    // Mapping from voter to mint approvals
    mapping(address => mapping(address => bool)) private _mintApprovals;

    // Mapping from owner to approval counts
    mapping(address => uint256) private _mintApprovalCounts;

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

    /// @notice Get voters addresses for this consensus contract
    /// @return Addresses of the voters
    function voters() public view virtual override returns (address[] memory) {
        return _votersArray;
    }

    /// @notice Cast a vote to mint a token for a specific address
    /// @param owner Address for whom to mint the token
    function approveMint(
        address owner,
        uint256 value,
        uint256 slot
    ) public virtual override {
        require(_voters[msg.sender], "You are not a voter");
        require(
            !_mintApprovals[msg.sender][owner],
            "You already approved this address"
        );
        _mintApprovals[msg.sender][owner] = true;
        _mintApprovalCounts[owner] += 1;
        if (_mintApprovalCounts[owner] == _votersArray.length) {
            _resetMintApprovals(owner);
            _mint(owner, value, slot);
        }
    }

    /// @notice Cast a vote to revoke a token for a specific address
    /// @param tokenId Identifier of the token to revoke
    function approveRevoke(uint256 tokenId) public virtual override {
        require(_voters[msg.sender], "You are not a voter");
        require(
            !_revokeApprovals[msg.sender][tokenId],
            "You already approved this address"
        );
        _revokeApprovals[msg.sender][tokenId] = true;
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

    function _resetMintApprovals(address owner) private {
        for (uint256 i = 0; i < _votersArray.length; i++) {
            _mintApprovals[_votersArray[i]][owner] = false;
        }
        _mintApprovalCounts[owner] = 0;
    }

    function _resetRevokeApprovals(uint256 tokenId) private {
        for (uint256 i = 0; i < _votersArray.length; i++) {
            _revokeApprovals[_votersArray[i]][tokenId] = false;
        }
        _revokeApprovalCounts[tokenId] = 0;
    }
}
