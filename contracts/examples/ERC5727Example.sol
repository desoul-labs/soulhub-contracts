// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../ERC5727/ERC5727Expirable.sol";
import "../ERC5727/ERC5727Governance.sol";
import "../ERC5727/ERC5727Delegate.sol";
import "../ERC5727/ERC5727Recovery.sol";
import "../ERC5727/ERC5727Registrant.sol";

contract ERC5727Example is
    ERC5727Recovery,
    ERC5727Expirable,
    ERC5727Governance,
    ERC5727Delegate,
    ERC5727Registrant
{
    string private _baseTokenURI;

    struct Slot {
        uint256 maxSupply;
        uint256 tokenCounts;
        uint256[] tokenFees;
        uint256[] tokenValues;
        uint256[] tokenExpiryDates;
        bool[] tokenShadowed;
    }

    mapping(uint256 => Slot) private _slots;

    event SlotAdded(uint256 indexed slot, uint256 maxSupply);

    constructor(
        string memory name,
        string memory symbol,
        address admin,
        address[] memory voters,
        string memory baseTokenURI
    ) ERC5727Governance(name, symbol, admin, voters) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            ERC5727Governance,
            ERC5727Delegate,
            ERC5727Expirable,
            ERC5727Recovery,
            ERC5727Registrant
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
