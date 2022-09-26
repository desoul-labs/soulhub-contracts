//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5342.sol";
import "./IERC5342Shadow.sol";

abstract contract ERC5342Shadow is ERC5342, IERC5342Shadow {
    mapping(uint256 => bool) private _shadowed;

    modifier onlyManager(uint256 tokenId) {
        require(
            _msgSender() == _getTokenOrRevert(tokenId).soul ||
                _msgSender() == _getTokenOrRevert(tokenId).issuer,
            "ERC5342Shadow: You are not the manager"
        );
        _;
    }

    function _beforeView(uint256 tokenId) internal view virtual override {
        require(
            !_shadowed[tokenId] ||
                _msgSender() == _getTokenOrRevert(tokenId).soul ||
                _msgSender() == _getTokenOrRevert(tokenId).issuer,
            "ERC5342Shadow: the token is shadowed"
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
        override(IERC165, ERC5342)
        returns (bool)
    {
        return
            interfaceId == type(IERC5342Shadow).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
