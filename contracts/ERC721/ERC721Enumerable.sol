// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ERC721.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    // Mapping from owner to list of owned token IDs
    mapping(address => EnumerableSet.UintSet) private _ownedTokens;

    EnumerableSet.UintSet private _allTokens;

    EnumerableSet.AddressSet private _allOwners;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721) returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index >= ERC721.balanceOf(owner))
            revert IndexOutOfBounds(index, ERC721.balanceOf(owner));
        return _ownedTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index >= ERC721Enumerable.totalSupply())
            revert IndexOutOfBounds(index, ERC721Enumerable.totalSupply());
        return _allTokens.at(index);
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert NotSupported();
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _allTokens.add(tokenId);
        } else if (from != to) {
            _ownedTokens[from].remove(tokenId);
        }
        if (to != address(0) && balanceOf(to) == 0) {
            _allOwners.add(to);
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);

        uint256 tokenId = firstTokenId;

        if (to == address(0)) {
            _allTokens.remove(tokenId);
        } else if (to != from) {
            _ownedTokens[to].add(tokenId);
        }
        if (from != address(0) && balanceOf(from) == 0) {
            _allOwners.remove(from);
        }
    }
}
