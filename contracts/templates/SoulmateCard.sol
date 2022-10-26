// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC5727/ERC5727Expirable.sol";
import "../ERC5727/ERC5727Enumerable.sol";

contract SoulmateCard is ERC5727Enumerable {
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC5727(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC5727Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mint(
        address soul,
        uint256 value,
        uint256 slot
    ) public returns (uint256) {
        return _mint(soul, value, slot);
    }
}
