// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727.sol";
import "./interfaces/IERC5727Governance.sol";

contract ERC5727Governance is IERC5727Governance, ERC5727 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _approvalRequestCount;

    enum ApprovalStatus {
        Pending,
        Approved,
        Rejected
    }

    struct IssueApproval {
        address creator;
        address to;
        address tokenId;
        uint256 value;
        uint256 slot;
        int256 approveNumber;
        ApprovalStatus approvalStatus;
        BurnAuth burnAuth;
    }

    mapping(uint256 => IssueApproval) private _approvals;

    EnumerableSet.AddressSet private _voters;

    bytes32 public constant VOTER_ROLE = bytes32(uint256(0x03));

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
    ) external virtual override {
        if(isVoter(_msgSender()))
            revert MethodNotAllowed(_msgSender()); 
        if(to == address(0)) 
            revert NullValue();

        approvalId = _approvalRequestCount; 
        
        unchecked {
            _approvalRequestCount ++;
        }
        _approvals[approvalId] = IssueApproval(_msgSender(), to, tokenId, amount, slot, 0, ApprovalStatus.Pending, burnAuth); 
        
        emit ApprovalUpdate(approvalId, _msgSender(), ApprovalStatus.Approved);
    }

    function removeApprovalRequest(
        uint256 approvalId
    ) external virtual override {
        if (_approvals[approvalId].creator == address(0))
            revert NotFound(approvalId);
        if (_msgSender() != _approvals[approvalId].creator)
            revert Unauthorized(_msgSender());

        delete _approvals[approvalId];

        unchecked {
            _approvalRequestCount --;
        }
        
        emit ApprovalUpdate(approvalId, address(0), ApprovalStatus.Removed);
    }

    function addVoter(address newVoter) public virtual onlyAdmin {
        if (newVoter == address(0)) revert NullValue();
        require(
            !hasRole(VOTER_ROLE, newVoter),
            "ERC5727Governance: newVoter is already a voter"
        );
        _voters.add(newVoter);
        _setupRole(VOTER_ROLE, newVoter);
    }

    function removeVoter(address voter) public virtual onlyAdmin {
        if (voter == address(0)) revert NullValue();
        require(
            _voters.contains(voter),
            "ERC5727Governance: Voter does not exist"
        );
        _revokeRole(VOTER_ROLE, voter);
        _voters.remove(voter);
    }

    function voterCount() public view virtual returns (uint256) {
        return _voters.length();
    }

    function voterByIndex(uint256 index) public view virtual returns (address) {
        if(index >= voterCount() || index < 0) 
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
    ) external virtual override {
        if(!isVoter(_msgSender()))
            revert MethodNotAllowed(_msgSender()); 
        if(_approvals[approvalId].creator == address(0))
            revert NotFound(approvalId);
        if(_approvals[approvalId].approvalStatus == ApprovalStatus.Approved) 
            revert Forbidden(); 
        if(_approvals[approvalId].approvalStatus == ApprovalStatus.Rejected) 
            revert Forbidden();   

        _approvals[approvalId].ApprovalStatus = ApprovalStatus.Approved;
        _approvals[approvalId].approveNumber += (approve == true);
    }

    function approvalURI(
        uint256 approvalId
    ) public view virtual override returns (string memory) {
        if (_approvals[approvalId].creator == address(0))
            revert NotFound(approvalId);

        return string(abi.encodePacked(_baseURI(), approvalId.toString()));
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Governance).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
