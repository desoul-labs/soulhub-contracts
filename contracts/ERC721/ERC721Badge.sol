// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Badge is ERC721Enumerable, Ownable {
    mapping(uint256 => bool) private _valid;

    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) Ownable() {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal pure override {
        require(from == address(0), "ERC721Badge: transfer is banned");
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
        _valid[tokenId] = true;
    }

    function revoke(uint256 tokenId) public onlyOwner {
        _valid[tokenId] = false;
    }

    function isValid(uint256 tokenId) public view returns (bool) {
        return _valid[tokenId];
    }
}
