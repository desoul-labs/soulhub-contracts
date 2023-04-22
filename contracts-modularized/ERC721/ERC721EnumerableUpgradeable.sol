// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interfaces/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./ERC721Upgradeable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is
    ERC721Upgradeable,
    IERC721EnumerableUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // Mapping from owner to list of owned token IDs
    mapping(address => EnumerableSetUpgradeable.UintSet) private _ownedTokens;

    EnumerableSetUpgradeable.UintSet private _allTokens;

    EnumerableSetUpgradeable.AddressSet private _allOwners;

    function __ERC721Enumerable_init() internal onlyInitializing {
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view virtual override returns (uint256) {
        if (index >= ERC721Upgradeable.balanceOf(owner))
            revert IndexOutOfBounds(index, ERC721Upgradeable.balanceOf(owner));
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
        if (index >= ERC721EnumerableUpgradeable.totalSupply())
            revert IndexOutOfBounds(
                index,
                ERC721EnumerableUpgradeable.totalSupply()
            );
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
