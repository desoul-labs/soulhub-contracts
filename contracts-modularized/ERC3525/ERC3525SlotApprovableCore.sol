// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC3525Core.sol";
import "./interfaces/IERC3525SlotApprovableUpgradeable.sol";
import "./ERC3525Storage.sol";

abstract contract ERC3525SlotApprovableCore is ERC3525Core {
    event ApprovalForSlot(
        address indexed _owner,
        uint256 indexed _slot,
        address indexed _operator,
        bool _approved
    );

    function setApprovalForSlot(
        address owner_,
        uint256 slot_,
        address operator_,
        bool approved_
    ) internal virtual {
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
    ) internal view virtual returns (bool) {
        return
            LibERC3525SlotApprovableStorage.s()._slotApprovals[owner_][slot_][
                operator_
            ];
    }

    function approve(
        address to_,
        uint256 tokenId_
    ) internal virtual override(ERC721Core) {
        address owner = ERC721Core.ownerOf(tokenId_);
        uint256 slot = ERC3525Core.slotOf(tokenId_);
        require(to_ != owner, "ERC3525: approval to current owner");

        require(
            _msgSender() == owner ||
                ERC721Core.isApprovedForAll(owner, _msgSender()) ||
                ERC3525SlotApprovableCore.isApprovedForSlot(
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
    ) internal virtual override(ERC3525Core) {
        address owner = ERC721Core.ownerOf(tokenId_);
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
        LibERC3525SlotApprovableStorage.s()._slotApprovals[owner_][slot_][
            operator_
        ] = approved_;
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
        address owner = ERC721Core.ownerOf(tokenId_);
        uint256 slot = ERC3525Core.slotOf(tokenId_);
        return (operator_ == owner ||
            getApproved(tokenId_) == operator_ ||
            ERC721Core.isApprovedForAll(owner, operator_) ||
            ERC3525SlotApprovableCore.isApprovedForSlot(
                owner,
                slot,
                operator_
            ));
    }
}
