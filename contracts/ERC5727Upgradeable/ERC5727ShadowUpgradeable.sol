//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727ShadowUpgradeable.sol";

abstract contract ERC5727ShadowUpgradeable is
    ERC5727Upgradeable,
    IERC5727ShadowUpgradeable
{
    mapping(uint256 => bool) private _shadowed;

    modifier onlyManager(uint256 tokenId) {
        require(
            _msgSender() == _getTokenOrRevert(tokenId).soul ||
                _msgSender() == _getTokenOrRevert(tokenId).issuer,
            "ERC5727Shadow: You are not the manager"
        );
        _;
    }

    function __ERC5727Shadow_init_unchained() internal onlyInitializing {}

    function __ERC5727Shadow_init() internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        __ERC5727Shadow_init_unchained();
    }

    function _beforeView(uint256 tokenId) internal view virtual override {
        require(
            !_shadowed[tokenId] ||
                _msgSender() == _getTokenOrRevert(tokenId).soul ||
                _msgSender() == _getTokenOrRevert(tokenId).issuer,
            "ERC5727Shadow: the token is shadowed"
        );
    }

    function _shadow(uint256 tokenId) internal virtual {
        _getTokenOrRevert(tokenId);
        _shadowed[tokenId] = true;
    }

    function _unshadow(uint256 tokenId) internal virtual {
        _getTokenOrRevert(tokenId);
        _shadowed[tokenId] = false;
    }

    function _isShadowed(uint256 tokenId) internal view virtual returns (bool) {
        _getTokenOrRevert(tokenId);
        return _shadowed[tokenId];
    }

    function isShadowed(uint256 tokenId)
        public
        view
        virtual
        override
        onlyManager(tokenId)
        returns (bool)
    {
        _getTokenOrRevert(tokenId);
        return _shadowed[tokenId];
    }

    function shadow(uint256 tokenId)
        public
        virtual
        override
        onlyManager(tokenId)
    {
        _shadowed[tokenId] = true;
    }

    function reveal(uint256 tokenId)
        public
        virtual
        override
        onlyManager(tokenId)
    {
        _shadowed[tokenId] = false;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727ShadowUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
