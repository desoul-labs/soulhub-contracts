// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../ERC5727Upgradeable/ERC5727EnumerableUpgradeable.sol";

contract SoulmateCardUpgradeable is
    Initializable,
    ERC5727EnumerableUpgradeable
{
    string private _baseTokenURI;
    string private _name;
    string private _symbol;

    function __SoulmateCard_init(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_
    ) internal onlyInitializing {
        __SoulmateCard_init_unchained(name_, symbol_, baseTokenURI_);
        __ERC5727_init_unchained(name_, symbol_);
    }

    function __SoulmateCard_init_unchained(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_
    ) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
        _baseTokenURI = baseTokenURI_;
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
        override(ERC5727EnumerableUpgradeable)
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
