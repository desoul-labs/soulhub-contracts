// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

import "../ERC5727/ERC5727Expirable.sol";
import "../ERC5727/ERC5727Governance.sol";
import "../ERC5727/ERC5727Delegate.sol";
import "../ERC5727/ERC5727Recovery.sol";
import "../ERC5727/ERC5727Registrant.sol";
import "../ERC5727/ERC5727Claimable.sol";

contract ERC5727Example is
    ERC2771Context,
    ERC5727Claimable,
    ERC5727Recovery,
    ERC5727Expirable,
    ERC5727Governance,
    ERC5727Delegate,
    ERC5727Registrant
{
    string private _baseTokenURI;

    constructor(
        string memory name,
        string memory symbol,
        address admin,
        address[] memory voters,
        string memory baseTokenURI,
        address trustedForwarder,
        string memory version
    )
        ERC2771Context(trustedForwarder)
        ERC5727Governance(name, symbol, admin, voters, version)
    {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _issue(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth auth
    ) internal virtual override(ERC5727, ERC5727Delegate) {
        ERC5727Delegate._issue(from, to, tokenId, amount, slot, auth);
    }

    function _revoke(
        address from,
        uint256 tokenId,
        uint256 amount
    ) internal virtual override(ERC5727, ERC5727Delegate) {
        ERC5727Delegate._revoke(from, tokenId, amount);
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._burn(tokenId);
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._beforeTokenTransfer(
            from,
            to,
            firstTokenId,
            batchSize
        );
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
            ERC5727Registrant,
            ERC5727Claimable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
