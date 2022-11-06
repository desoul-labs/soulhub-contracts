// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";

import "./ERC5727ExampleUpgradeable.sol";

contract Souldrop is ERC721EnumerableUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    CountersUpgradeable.Counter private _tokenIdCounter;

    string private _baseTokenURI;

    ERC5727ExampleUpgradeable private erc5727;

    EnumerableMapUpgradeable.AddressToUintMap private _snapshot;

    function initialize(
        address owner,
        uint256 threshold,
        string memory baseTokenURI,
        address erc5727Address
    ) public initializer {
        __Ownable_init_unchained();
        __ERC721_init_unchained("Souldrop", "SDP");
        __ERC721Enumerable_init_unchained();
        _transferOwnership(owner);

        _baseTokenURI = baseTokenURI;

        erc5727 = ERC5727ExampleUpgradeable(erc5727Address);
        uint256 total = erc5727.emittedCount();
        for (uint256 i = 0; i < total; i++) {
            address soul = erc5727.soulOf(i);
            (bool exist, uint256 val) = _snapshot.tryGet(soul);
            _snapshot.set(soul, erc5727.valueOf(i) + val);
        }
        for (uint256 i = 0; i < _snapshot.length(); i++) {
            (address soul, uint256 value) = _snapshot.at(i);
            if (value >= threshold) {
                _safeMint(soul);
            }
        }
    }

    function _safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _baseURI();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
