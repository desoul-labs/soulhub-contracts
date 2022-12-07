//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727EnumerableUpgradeable.sol";

abstract contract ERC5727EnumerableUpgradeable is
    ERC5727Upgradeable,
    IERC5727EnumerableUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping(address => EnumerableSetUpgradeable.UintSet)
        private _indexedTokenIds;
    mapping(address => uint256) private _numberOfValidTokens;

    CountersUpgradeable.Counter private _emittedCount;
    CountersUpgradeable.Counter private _soulsCount;

    function __ERC5727Enumerable_init_unchained() internal onlyInitializing {}

    function __ERC5727Enumerable_init() internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        __ERC5727Enumerable_init_unchained();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual override {
        if (EnumerableSetUpgradeable.length(_indexedTokenIds[soul]) == 0) {
            CountersUpgradeable.increment(_soulsCount);
        }
    }

    function _afterTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual override {
        EnumerableSetUpgradeable.add(_indexedTokenIds[soul], tokenId);
        if (valid) {
            _numberOfValidTokens[soul] += 1;
        }
    }

    function _mint(
        address soul,
        uint256 value,
        uint256 slot
    ) internal virtual returns (uint256 tokenId) {
        tokenId = CountersUpgradeable.current(_emittedCount);
        _mintUnsafe(soul, tokenId, value, slot, true);
        emit Minted(soul, tokenId, value);
        CountersUpgradeable.increment(_emittedCount);
    }

    function _mint(
        address issuer,
        address soul,
        uint256 value,
        uint256 slot
    ) internal virtual returns (uint256 tokenId) {
        tokenId = CountersUpgradeable.current(_emittedCount);
        _mintUnsafe(issuer, soul, tokenId, value, slot, true);
        emit Minted(soul, tokenId, value);
        CountersUpgradeable.increment(_emittedCount);
    }

    function _mintBatch(
        address[] memory souls,
        uint256[] memory values,
        uint256[] memory slots
    ) internal virtual returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](souls.length);
        for (uint256 i = 0; i < souls.length; i++) {
            tokenIds[i] = _mint(souls[i], values[i], slots[i]);
        }
    }

    function _afterTokenRevoke(uint256 tokenId) internal virtual override {
        assert(_numberOfValidTokens[_getTokenOrRevert(tokenId).soul] > 0);
        _numberOfValidTokens[_getTokenOrRevert(tokenId).soul] -= 1;
    }

    function _beforeTokenDestroy(uint256 tokenId) internal virtual override {
        address soul = soulOf(tokenId);

        if (_getTokenOrRevert(tokenId).valid) {
            assert(_numberOfValidTokens[soul] > 0);
            _numberOfValidTokens[soul] -= 1;
        }
        EnumerableSetUpgradeable.remove(_indexedTokenIds[soul], tokenId);
        if (EnumerableSetUpgradeable.length(_indexedTokenIds[soul]) == 0) {
            assert(CountersUpgradeable.current(_soulsCount) > 0);
            CountersUpgradeable.decrement(_soulsCount);
        }
    }

    function _increaseEmittedCount() internal {
        CountersUpgradeable.increment(_emittedCount);
    }

    function _tokensOfSoul(
        address soul
    ) internal view returns (uint256[] memory tokenIds) {
        tokenIds = EnumerableSetUpgradeable.values(_indexedTokenIds[soul]);
        require(tokenIds.length != 0, "ERC5727: the soul has no token");
    }

    function emittedCount() public view virtual override returns (uint256) {
        return CountersUpgradeable.current(_emittedCount);
    }

    function soulsCount() public view virtual override returns (uint256) {
        return CountersUpgradeable.current(_soulsCount);
    }

    function balanceOf(
        address soul
    ) public view virtual override returns (uint256) {
        return EnumerableSetUpgradeable.length(_indexedTokenIds[soul]);
    }

    function hasValid(
        address soul
    ) public view virtual override returns (bool) {
        return _numberOfValidTokens[soul] > 0;
    }

    function tokenOfSoulByIndex(
        address soul,
        uint256 index
    ) public view virtual override returns (uint256) {
        EnumerableSetUpgradeable.UintSet storage ids = _indexedTokenIds[soul];
        require(
            index < EnumerableSetUpgradeable.length(ids),
            "ERC5727: Token does not exist"
        );
        return EnumerableSetUpgradeable.at(ids, index);
    }

    function tokenByIndex(
        uint256 index
    ) public view virtual override returns (uint256) {
        return index;
    }
}
