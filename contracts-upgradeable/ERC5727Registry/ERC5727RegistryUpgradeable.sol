// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "../ERC721/ERC721EnumerableUpgradeable.sol";
import "../ERC721/ERC721PausableUpgradeable.sol";
import "../ERC5727/interfaces/IERC5727MetadataUpgradeable.sol";
import "../ERC5727/interfaces/IERC5727Upgradeable.sol";
import "./interfaces/IERC5727RegistryUpgradeable.sol";

contract ERC5727RegistryUpgradeable is
    ContextUpgradeable,
    IERC5727RegistryUpgradeable,
    ERC721PausableUpgradeable,
    ERC721EnumerableUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using ERC165CheckerUpgradeable for address;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;
    using StringsUpgradeable for address;

    string private _uri;

    CountersUpgradeable.Counter private _entryIdCounter;

    EnumerableMapUpgradeable.UintToAddressMap private _entries;
    EnumerableMapUpgradeable.AddressToUintMap private _indexedEntries;

    modifier onlyERC5727Contract(address addr) {
        bool isERC5727Contract = addr.supportsInterface(
            type(IERC5727MetadataUpgradeable).interfaceId
        );
        if (!isERC5727Contract) revert NotSupported();
        _;
    }

    function __ERC5727Registry_init(
        string memory name_,
        string memory namespace_,
        string memory uri_
    ) public initializer {
        __ERC721_init_unchained(name_, namespace_);
        __ERC5727Registry_init_unchained(uri_);
    }

    function __ERC5727Registry_init_unchained(
        string memory uri_
    ) internal onlyInitializing {
        _uri = uri_;
    }

    function _setEntry(uint256 entry, address addr) internal virtual {
        bool success = _entries.set(entry, addr);
        bool successIndex = _indexedEntries.set(addr, entry);

        require(success && successIndex, "Entry already exists");
    }

    function _removeEntry(uint256 entry) internal virtual {
        address addr = addressOf(entry);
        bool success = _entries.remove(entry);
        bool successIndex = _indexedEntries.remove(addr);

        require(success && successIndex, "Entry does not exist");
    }

    function register(
        address addr
    ) public virtual override onlyERC5727Contract(addr) returns (uint256) {
        if (isRegistered(addr)) revert("Address already registered");

        uint256 tokenId = _register(addr);
        string memory uri = IERC5727MetadataUpgradeable(addr).contractURI();
        _safeMint(_msgSender(), tokenId, uri);

        return tokenId;
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) internal {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _register(address addr) internal virtual returns (uint256) {
        _entryIdCounter.increment();
        uint256 entry = _entryIdCounter.current();
        _setEntry(entry, addr);

        emit Registered(entry, addr);

        return entry;
    }

    function deregister(
        address addr
    ) public virtual override onlyERC5727Contract(addr) returns (uint256) {
        if (!isRegistered(addr)) revert("Address not registered");

        uint256 tokenId = _deregister(addr);

        return tokenId;
    }

    function _deregister(address addr) internal virtual returns (uint256) {
        uint256 entry = entryOf(addr);
        if (!_isApprovedOrOwner(_msgSender(), entry))
            revert Unauthorized(_msgSender());
        _burn(entry);
        _removeEntry(entry);

        emit Deregistered(entry, addr);

        return entry;
    }

    function transferOwnership(
        address addr,
        address newOwner
    ) public virtual override onlyERC5727Contract(addr) {
        safeTransferFrom(_msgSender(), newOwner, entryOf(addr));
    }

    function isRegistered(
        address addr
    ) public view virtual override returns (bool) {
        return _indexedEntries.contains(addr);
    }

    function addressOf(
        uint256 entry
    ) public view virtual override returns (address) {
        (bool exists, address addr) = _entries.tryGet(entry);
        if (!exists) revert NotFound(entry);

        return addr;
    }

    function entryOf(
        address addr
    ) public view virtual override returns (uint256) {
        (bool exists, uint256 entry) = _indexedEntries.tryGet(addr);
        if (!exists) revert NotRegistered(addr);

        return entry;
    }

    function registryURI()
        external
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(_uri).length > 0
                ? string(abi.encodePacked(_uri, address(this).toHexString()))
                : "";
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721PausableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            IERC165Upgradeable,
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return
            interfaceId == type(IERC5727RegistryUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
