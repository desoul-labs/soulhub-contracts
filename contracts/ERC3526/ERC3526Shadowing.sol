//SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./ERC3526.sol";

abstract contract ERC3526Shadowing is ERC3526 {
    mapping(uint256 => bool) private _isShadowed;

    /**
     * @notice get the owner of a token and revert if it does not exist.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            !_isShadowed[tokenId] ||
                _msgSender() == _getTokenOrRevert(tokenId).owner,
            "ERC3526Shadowing: the token is shadowed"
        );
        return _getTokenOrRevert(tokenId).owner;
    }

    /**
     * @notice get the slot of a token and revert if it does not exist.
     */
    function slotOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            !_isShadowed[tokenId] ||
                _msgSender() == _getTokenOrRevert(tokenId).owner,
            "ERC3526Shadowing: the token is shadowed"
        );
        return _getTokenOrRevert(tokenId).slot;
    }

    /**
     * @notice URI to query to get the token's metadata
     * @param tokenId Identifier of the token
     * @return URI for the token
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            !_isShadowed[tokenId] ||
                _msgSender() == _getTokenOrRevert(tokenId).owner,
            "ERC3526Shadowing: the token is shadowed"
        );
        _exists(tokenId);
        bytes memory baseURI = bytes(_baseURI());
        if (baseURI.length > 0) {
            return
                string(
                    abi.encodePacked(baseURI, Strings.toHexString(tokenId, 32))
                );
        }
        return "";
    }

    function _shadow(uint256 tokenId) internal virtual {
        _isShadowed[tokenId] = true;
    }
}
