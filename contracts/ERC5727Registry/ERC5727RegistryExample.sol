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
import "../ERC5727/ERC5727Registrant.sol";
import "./ERC5727Registry.sol";

contract ERC5727RegistryExample is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC5727Registry
{
    using ERC165Checker for address;

    modifier onlyOwnable() {
        (bool success, bytes memory data) = _msgSender().delegatecall(
            abi.encodeWithSignature("owner()")
        );
        require(success, "Only Ownable contract can call this function");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory namespace,
        string memory uri
    ) ERC721(name, symbol) ERC5727Registry(name, namespace, uri) {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) internal {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function register(address addr) public onlyOwnable returns (uint256) {
        uint256 tokenId = _register(addr);
        address owner = Ownable(addr).owner();
        string memory uri = IERC5727Metadata(addr).contractURI();
        _safeMint(owner, tokenId, uri);

        return tokenId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from != address(0) && to != address(0)) {
            address addr = addressOf(tokenId);
            ERC5727Registrant(addr).registryTransferOwnership(to);
        }
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function deregister(address addr)
        public
        override
        onlyOwnable
        returns (uint256)
    {
        uint256 tokenId = _deregister(addr);
        _burn(tokenId);

        return tokenId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC5727Registry)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
