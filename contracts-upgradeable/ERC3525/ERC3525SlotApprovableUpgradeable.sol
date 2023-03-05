// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC3525Upgradeable.sol";
import "./interfaces/IERC3525SlotApprovableUpgradeable.sol";

abstract contract ERC3525SlotApprovableUpgradeable is
    ERC3525Upgradeable,
    IERC3525SlotApprovableUpgradeable
{
    // @dev owner => slot => operator => approved
    mapping(address => mapping(uint256 => mapping(address => bool)))
        private _slotApprovals;

    function __ERC3525SlotApprovable_init() internal onlyInitializing {
        __ERC3525SlotApprovable_init_unchained();
    }

    function __ERC3525SlotApprovable_init_unchained()
        internal
        onlyInitializing
    {}

    function setApprovalForSlot(
        address owner_,
        uint256 slot_,
        address operator_,
        bool approved_
    ) external payable virtual override {
        require(
            _msgSender() == owner_ || isApprovedForAll(owner_, _msgSender()),
            "ERC3525SlotApprovable: caller is not owner nor approved for all"
        );
        _setApprovalForSlot(owner_, slot_, operator_, approved_);
    }

    function isApprovedForSlot(
        address owner_,
        uint256 slot_,
        address operator_
    ) public view virtual override returns (bool) {
        return _slotApprovals[owner_][slot_][operator_];
    }

    function approve(
        address to_,
        uint256 tokenId_
    ) public virtual override(IERC721Upgradeable, ERC721Upgradeable) {
        address owner = ERC721Upgradeable.ownerOf(tokenId_);
        uint256 slot = ERC3525Upgradeable.slotOf(tokenId_);
        require(to_ != owner, "ERC3525: approval to current owner");

        require(
            _msgSender() == owner ||
                ERC721Upgradeable.isApprovedForAll(owner, _msgSender()) ||
                ERC3525SlotApprovableUpgradeable.isApprovedForSlot(
                    owner,
                    slot,
                    _msgSender()
                ),
            "ERC3525: caller is not owner nor approved"
        );

        _approve(to_, tokenId_);
    }

    function approve(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) public payable virtual override(IERC3525Upgradeable, ERC3525Upgradeable) {
        address owner = ERC721Upgradeable.ownerOf(tokenId_);
        require(to_ != owner, "ERC3525: approval to current owner");

        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "ERC3525: caller is not owner nor approved"
        );

        _approve(tokenId_, to_, value_);
    }

    function _setApprovalForSlot(
        address owner_,
        uint256 slot_,
        address operator_,
        bool approved_
    ) internal virtual {
        require(owner_ != operator_, "ERC3525SlotApprovable: approve to owner");
        _slotApprovals[owner_][slot_][operator_] = approved_;
        emit ApprovalForSlot(owner_, slot_, operator_, approved_);
    }

    function _isApprovedOrOwner(
        address operator_,
        uint256 tokenId_
    ) internal view virtual override returns (bool) {
        require(
            _exists(tokenId_),
            "ERC3525: operator query for nonexistent token"
        );
        address owner = ERC721Upgradeable.ownerOf(tokenId_);
        uint256 slot = ERC3525Upgradeable.slotOf(tokenId_);
        return (operator_ == owner ||
            getApproved(tokenId_) == operator_ ||
            ERC721Upgradeable.isApprovedForAll(owner, operator_) ||
            ERC3525SlotApprovableUpgradeable.isApprovedForSlot(
                owner,
                slot,
                operator_
            ));
    }
}
