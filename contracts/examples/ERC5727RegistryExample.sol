// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../ERC5727/ERC5727Registrant.sol";
import "../ERC5727Registry/ERC5727Registry.sol";

contract ERC5727RegistryExample is ERC5727Registry {
    using ERC165Checker for address;
    using Address for address;

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
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        require(
            _isERC5727Contract(_msgSender()),
            "Only ERC5727 contract can call this function"
        );
        if (from != address(0)) {
            address addr = addressOf(tokenId);
            require(
                ERC5727Registrant(addr).owner() == from,
                "ERC5727Registry: Only registrant owner can transfer"
            );
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyOwnable {
        _safeTransfer(from, to, tokenId, "");
    }

    function deregister(address addr) public onlyOwnable returns (uint256) {
        uint256 tokenId = _deregister(addr);
        return tokenId;
    }
}
