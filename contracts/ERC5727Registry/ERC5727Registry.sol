// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "../ERC5727/interfaces/IERC5727.sol";
import "../ERC5727/interfaces/IERC5727Metadata.sol";
import "./IERC5727Registry.sol";
import "./IERC5727RegistryMetadata.sol";

abstract contract ERC5727Registry is
    Context,
    ERC165,
    IERC5727Registry,
    IERC5727RegistryMetadata
{
    using Counters for Counters.Counter;
    using ERC165Checker for address;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    modifier onlyERC5727() {
        require(
            _msgSender().supportsInterface(type(IERC5727).interfaceId) &&
                _msgSender().supportsInterface(
                    type(IERC5727Metadata).interfaceId
                ),
            "Only ERC5727 contract can call this function"
        );
        _;
    }

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
        bool success = _entries.remove(id);
        bool successIndex = _indexedEntries.remove(addressOf(id));

        require(success && successIndex, "Entry does not exist");
    }

    function _register(address addr) public onlyERC5727 returns (uint256) {
        require(
            addr == _msgSender(),
            "Only ERC5727 contract can register itself"
        );
        uint256 id = _entryIdCounter.current();
        _entryIdCounter.increment();
        _setEntry(id, addr);

        emit Registered(id, addr);

        return id;
    }

    function _deregister(address addr) public onlyERC5727 returns (uint256) {
        require(
            addr == _msgSender(),
            "Only ERC5727 contract can deregister itself"
        );
        uint256 id = idOf(addr);
        _removeEntry(id);

        emit Deregistered(id, addr);

        return id;
    }

    function isRegistered(address addr) external view override returns (bool) {
        return _indexedEntries.contains(addr);
    }

    function addressOf(uint256 id) public view override returns (address) {
        (bool exists, address addr) = _entries.tryGet(id);
        require(exists, "ERC5727Registry: entry not found");
        return addr;
    }

    function idOf(address addr) public view override returns (uint256) {
        (bool exists, uint256 id) = _indexedEntries.tryGet(addr);
        require(exists, "ERC5727Registry: entry not found");
        return id;
    }

    function registryURI() external view returns (string memory) {
        return _uri;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727Registry).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
