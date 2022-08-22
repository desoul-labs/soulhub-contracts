// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./ERC4671/ERC4671Consensus.sol";
import "./ERC4671/ERC4671Delegate.sol";
import "./ERC4671/ERC4671.sol";

contract MembershipCard is ERC4671Delegate, ERC4671Consensus {
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        address[] memory voters
    ) ERC4671Consensus(name, symbol, voters) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC4671Delegate, ERC4671Consensus) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
