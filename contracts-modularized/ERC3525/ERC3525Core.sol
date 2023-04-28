//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "../ERC721/ERC721EnumerableUpgradeable.sol";
import "../ERC721/ERC721EnumerableCore.sol";
import "./interfaces/IERC3525Upgradeable.sol";
import "./interfaces/IERC3525MetadataUpgradeable.sol";
import "./ERC3525Storage.sol";
import "../ERC721/ERC721Storage.sol";

contract ERC3525Core is ERC721EnumerableCore {
    using AddressUpgradeable for address;
    using StringsUpgradeable for address;
    using StringsUpgradeable for uint256;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    /**
     * @dev MUST emit when value of a token is transferred to another token with the same slot,
     *  including zero value transfers (_value == 0) as well as transfers when tokens are created
     *  (`_fromTokenId` == 0) or destroyed (`_toTokenId` == 0).
     * @param _fromTokenId The token id to transfer value from
     * @param _toTokenId The token id to transfer value to
     * @param _value The transferred value
     */
    event TransferValue(
        uint256 indexed _fromTokenId,
        uint256 indexed _toTokenId,
        uint256 _value
    );

    /**
     * @dev MUST emits when the approval value of a token is set or changed.
     * @param _tokenId The token to approve
     * @param _operator The operator to approve for
     * @param _value The maximum value that `_operator` is allowed to manage
     */
    event ApprovalValue(
        uint256 indexed _tokenId,
        address indexed _operator,
        uint256 _value
    );

    /**
     * @dev MUST emit when the slot of a token is set or changed.
     * @param _tokenId The token of which slot is set or changed
     * @param _oldSlot The previous slot of the token
     * @param _newSlot The updated slot of the token
     */
    event SlotChanged(
        uint256 indexed _tokenId,
        uint256 indexed _oldSlot,
        uint256 indexed _newSlot
    );

    function valueDecimals() internal view returns (uint8) {
        return LibERC3525Storage.s()._decimals;
    }

    function balanceOf(uint256 tokenId) internal view returns (uint256) {
        _requireMinted(tokenId);

        return LibERC3525Storage.s()._values[tokenId];
    }

    function slotOf(uint256 tokenId) internal view returns (uint256) {
        _requireMinted(tokenId);

        return LibERC3525Storage.s()._slots[tokenId];
    }

    function contractURI() internal view virtual returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, address(this).toHexString()))
                : "";
    }

    function slotURI(
        uint256 slot
    ) internal view virtual returns (string memory) {
        string memory contractUri = contractURI();
        return
            bytes(contractUri).length > 0
                ? string(
                    abi.encodePacked(contractUri, "/slots/", slot.toString())
                )
                : "";
    }

    function tokenURI(
        uint256 tokenId
    ) internal view virtual override(ERC721Core) returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = LibERC721Storage.s()._tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }

        string memory contractUri = contractURI();
        return
            bytes(contractUri).length > 0
                ? string(
                    abi.encodePacked(
                        contractUri,
                        "/tokens/",
                        tokenId.toString()
                    )
                )
                : "";
    }

    function approve(
        uint256 tokenId,
        address to,
        uint256 value
    ) internal virtual {
        approve(to, tokenId);

        if (!ERC721Core._isApprovedOrOwner(_msgSender(), tokenId))
            revert Unauthorized(_msgSender());

        _approve(tokenId, to, value);
    }

    function allowance(
        uint256 tokenId,
        address operator
    ) internal view virtual returns (uint256) {
        return LibERC3525Storage.s()._valueApprovals[tokenId].get(operator);
    }

    function transferFrom(
        uint256 fromTokenId,
        address to,
        uint256 value
    ) internal virtual returns (uint256) {
        _spendAllowance(_msgSender(), fromTokenId, value);

        uint256 newTokenId = _getNewTokenId(fromTokenId);
        _mint(to, newTokenId, LibERC3525Storage.s()._slots[fromTokenId]);
        _transfer(fromTokenId, newTokenId, value);

        return newTokenId;
    }

    function transferFrom(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 value
    ) internal virtual {
        _spendAllowance(_msgSender(), fromTokenId, value);

        if (
            LibERC3525Storage.s()._slots[fromTokenId] !=
            LibERC3525Storage.s()._slots[toTokenId]
        )
            revert Mismatch(
                LibERC3525Storage.s()._slots[fromTokenId],
                LibERC3525Storage.s()._slots[toTokenId]
            );

        _transfer(fromTokenId, toTokenId, value);
    }

    function _mint(address to, uint256 tokenId, uint256 slot) internal virtual {
        if (tokenId == 0 || slot == 0) revert NullValue();

        ERC721Core._mint(to, tokenId);
        LibERC3525Storage.s()._slots[tokenId] = slot;

        emit SlotChanged(tokenId, 0, slot);
    }

    function _mint(uint256 tokenId, uint256 value) internal virtual {
        _requireMinted(tokenId);

        address owner = ownerOf(tokenId);
        uint256 slot = slotOf(tokenId);

        _beforeValueTransfer(address(0), owner, 0, tokenId, slot, value);

        LibERC3525Storage.s()._values[tokenId] = value;
        emit TransferValue(0, tokenId, value);

        _afterValueTransfer(address(0), owner, 0, tokenId, slot, value);
    }

    function _burn(uint256 tokenId) internal virtual override {
        address owner = ERC721Core.ownerOf(tokenId);
        ERC721Core._burn(tokenId);

        uint256 slot = LibERC3525Storage.s()._slots[tokenId];
        uint256 value = LibERC3525Storage.s()._values[tokenId];

        _beforeValueTransfer(owner, address(0), tokenId, 0, slot, value);

        delete LibERC3525Storage.s()._slots[tokenId];
        delete LibERC3525Storage.s()._values[tokenId];

        _afterValueTransfer(owner, address(0), tokenId, 0, slot, value);

        emit TransferValue(tokenId, 0, value);
        emit SlotChanged(tokenId, slot, 0);
    }

    function _burn(uint256 tokenId, uint256 value) internal virtual {
        address owner = ERC721Core.ownerOf(tokenId);
        uint256 slot = LibERC3525Storage.s()._slots[tokenId];

        if (LibERC3525Storage.s()._values[tokenId] < value)
            revert InsufficientBalance(
                LibERC3525Storage.s()._values[tokenId],
                value
            );

        _beforeValueTransfer(owner, address(0), tokenId, 0, slot, value);

        delete LibERC3525Storage.s()._valueApprovals[tokenId];

        LibERC3525Storage.s()._values[tokenId] -= value;

        _afterValueTransfer(owner, address(0), tokenId, 0, slot, value);

        emit TransferValue(tokenId, 0, value);
    }

    function _transfer(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 value
    ) internal virtual {
        address from = ERC721Core.ownerOf(fromTokenId);
        address to = ERC721Core.ownerOf(toTokenId);
        uint256 slot = LibERC3525Storage.s()._slots[fromTokenId];

        _beforeValueTransfer(from, to, fromTokenId, toTokenId, slot, value);

        delete LibERC3525Storage.s()._valueApprovals[fromTokenId];

        LibERC3525Storage.s()._values[fromTokenId] -= value;
        LibERC3525Storage.s()._values[toTokenId] += value;

        _afterValueTransfer(from, to, fromTokenId, toTokenId, slot, value);

        emit TransferValue(fromTokenId, toTokenId, value);
    }

    function _spendAllowance(
        address operator,
        uint256 tokenId,
        uint256 value
    ) internal virtual {
        if (ownerOf(tokenId) == operator) return;
        uint256 currentAllowance = ERC3525Core.allowance(tokenId, operator);
        if (
            !_isApprovedOrOwner(operator, tokenId) &&
            currentAllowance != type(uint256).max
        ) {
            if (currentAllowance < value)
                revert InsufficientBalance(currentAllowance, value);

            _approve(tokenId, operator, currentAllowance - value);
        }
    }

    function _approve(
        uint256 tokenId,
        address to,
        uint256 value
    ) internal virtual {
        LibERC3525Storage.s()._valueApprovals[tokenId].set(to, value);

        emit ApprovalValue(tokenId, to, value);
    }

    function _getNewTokenId(
        uint256 fromTokenId
    ) internal virtual returns (uint256) {
        fromTokenId;

        return ERC721EnumerableCore.totalSupply() + 1;
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual {
        from;
        to;
        fromTokenId;
        toTokenId;
        slot;
        value;
    }

    function _afterValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual {
        from;
        to;
        fromTokenId;
        toTokenId;
        slot;
        value;
    }
}
