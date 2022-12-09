// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "../ERC5727/interfaces/IERC5727.sol";
import "../ERC5727/interfaces/IERC5727Metadata.sol";
import "../ERC5727/interfaces/IERC5727Registrant.sol";
import "./interfaces/IERC5727Registry.sol";
import "./interfaces/IERC5727RegistryMetadata.sol";

abstract contract ERC5727Registry is
    Context,
    ERC165,
    IERC5727Registry,
    IERC5727RegistryMetadata,
    ERC721Enumerable,
    ERC721URIStorage
{
    using Counters for Counters.Counter;
    using ERC165Checker for address;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for address;

    string private _name;
    string private _namespace;
    string private _uri;

    Counters.Counter private _entryIdCounter;

    EnumerableMap.UintToAddressMap private _entries;
    EnumerableMap.AddressToUintMap private _indexedEntries;

    constructor(
        string memory name,
        string memory namespace,
        string memory uri
    ) {
        _name = name;
        _namespace = namespace;
        _uri = uri;
    }

    function _setEntry(uint256 id, address addr) internal {
        bool success = _entries.set(id, addr);
        bool successIndex = _indexedEntries.set(addr, id);

        require(success && successIndex, "Entry already exists");
    }

    function _removeEntry(uint256 id) internal {
        address addr = addressOf(id);
        bool success = _entries.remove(id);
        bool successIndex = _indexedEntries.remove(addr);

        require(success && successIndex, "Entry does not exist");
    }

    function _register(address addr) public virtual returns (uint256) {
        require(
            _isERC5727Contract(addr),
            "Only ERC5727 contract can be registered"
        );

        uint256 id = _entryIdCounter.current();
        _entryIdCounter.increment();
        _setEntry(id, addr);

        emit Registered(id, addr);

        return id;
    }

    function _deregister(address addr) public virtual returns (uint256) {
        require(
            _isERC5727Contract(addr),
            "Only ERC5727 contract can be deregistered"
        );

        uint256 id = idOf(addr);
        _burn(id);
        _removeEntry(id);

        emit Deregistered(id, addr);

        return id;
    }

    function isRegistered(
        address addr
    ) external view virtual override returns (bool) {
        return _indexedEntries.contains(addr);
    }

    function addressOf(
        uint256 id
    ) public view virtual override returns (address) {
        (bool exists, address addr) = _entries.tryGet(id);
        require(exists, "ERC5727Registry: entry not found");
        return addr;
    }

    function idOf(address addr) public view virtual override returns (uint256) {
        (bool exists, uint256 id) = _indexedEntries.tryGet(addr);
        require(exists, "ERC5727Registry: entry not found");
        return id;
    }

    function total() external view override returns (uint256) {
        return _entryIdCounter.current();
    }

    function registryURI() external view returns (string memory) {
        return
            bytes(_uri).length > 0
                ? string(abi.encodePacked(_uri, address(this).toHexString()))
                : "";
    }

    function _isERC5727Contract(address addr) internal view returns (bool) {
        return
            addr.supportsInterface(type(IERC5727).interfaceId) &&
            addr.supportsInterface(type(IERC5727Metadata).interfaceId) &&
            addr.supportsInterface(type(IERC5727Registrant).interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC165, IERC165, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727Registry).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
