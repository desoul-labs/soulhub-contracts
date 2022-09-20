// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "../ERC3526/ERC3526Expirable.sol";
import "../ERC3526/ERC3526Consensus.sol";
import "../ERC3526/ERC3526Delegate.sol";
import "../ERC3526/ERC3526Shadowing.sol";
import "../ERC3526/ERC3526SlotEnumerable.sol";

contract Perk is
    ERC3526Expirable,
    ERC3526Consensus,
    ERC3526Delegate,
    ERC3526SlotEnumerable
{
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory voters,
        string memory baseTokenURI
    ) ERC3526Consensus(name, symbol, voters) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC3526, IERC165, ERC3526Consensus, ERC3526Delegate)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
