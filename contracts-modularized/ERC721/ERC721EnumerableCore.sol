// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./ERC721Storage.sol";

import "./ERC721Core.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
contract ERC721EnumerableCore is ERC721Core {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    // function supportsInterface(
    //     bytes4 interfaceId
    // )
    //     public
    //     view
    //     virtual
    //     override(IERC165Upgradeable, ERC721Upgradeable)
    //     returns (bool)
    // {
    //     return
    //         interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) internal view returns (uint256) {
        if (index >= ERC721Core.balanceOf(owner))
            revert IndexOutOfBounds(index, ERC721Core.balanceOf(owner));
        return
            LibERC721EnumerableUpgradeableStorage.s()._ownedTokens[owner].at(
                index
            );
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() internal view returns (uint256) {
        return LibERC721EnumerableUpgradeableStorage.s()._allTokens.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) internal view returns (uint256) {
        if (index >= ERC721EnumerableCore.totalSupply())
            revert IndexOutOfBounds(index, ERC721EnumerableCore.totalSupply());
        return LibERC721EnumerableUpgradeableStorage.s()._allTokens.at(index);
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
            LibERC721EnumerableUpgradeableStorage.s()._allTokens.add(tokenId);
        } else if (from != to) {
            LibERC721EnumerableUpgradeableStorage.s()._ownedTokens[from].remove(
                tokenId
            );
        }
        if (to != address(0) && balanceOf(to) == 0) {
            LibERC721EnumerableUpgradeableStorage.s()._allOwners.add(to);
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
            LibERC721EnumerableUpgradeableStorage.s()._allTokens.remove(
                tokenId
            );
        } else if (to != from) {
            LibERC721EnumerableUpgradeableStorage.s()._ownedTokens[to].add(
                tokenId
            );
        }
        if (from != address(0) && balanceOf(from) == 0) {
            LibERC721EnumerableUpgradeableStorage.s()._allOwners.remove(from);
        }
    }
}
