//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5342.sol";

abstract contract ERC5342Shadow is ERC5342 {
    mapping(uint256 => bool) private _shadowed;

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
}
