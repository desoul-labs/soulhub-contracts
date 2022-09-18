// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "../ERC3526/ERC3526Expirable.sol";

contract SoulmateCard is ERC3526Expirable {
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC3526(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC3526, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mintNonFungible(address owner, uint256 slot) public onlyOwner {
        require(slot != 0, "SoulmateCard: slot 0 is for points");
        _mint(owner, 1, slot);
    }

    function mintFungible(address owner, uint256 value) public onlyOwner {
        _mint(owner, value, 0);
    }
}
