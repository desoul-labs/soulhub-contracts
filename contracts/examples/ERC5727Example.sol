// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../ERC5727/ERC5727Expirable.sol";
import "../ERC5727/ERC5727Governance.sol";
import "../ERC5727/ERC5727Delegate.sol";
import "../ERC5727/ERC5727Recovery.sol";
import "../ERC5727/ERC5727Claimable.sol";

contract ERC5727Example is
    ERC5727Claimable,
    ERC5727Recovery,
    ERC5727Expirable,
    ERC5727Governance,
    ERC5727Delegate
{
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        address admin,
        string memory baseTokenURI,
        string memory version
    ) ERC5727Governance(name, symbol, admin, version) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }

    function _afterValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override(ERC3525, ERC5727Enumerable) {
        ERC5727Enumerable._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }

    function batchIssue(
        address[] calldata to,
        uint256 slot,
        string calldata uri,
        bytes calldata data
    ) external virtual onlyAdmin {
        uint256 next = totalSupply() + 1;
        for (uint256 i = 0; i < to.length; i++) {
            issue(
                to[i],
                next + i,
                slot,
                BurnAuth.IssuerOnly,
                address(this),
                data
            );
            _setTokenURI(next + i, uri);
        }
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
            ERC5727Claimable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
