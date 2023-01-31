// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interfaces/IERC5727Delegate.sol";
import "./ERC5727.sol";

abstract contract ERC5727Delegate is IERC5727Delegate, ERC5727 {
    struct DelegatedIssue {
        address operator;
        address to;
        uint256 value;
        uint256 slot;
        BurnAuth burnAuth;
    }

    struct DelegatedRevoke {
        address operator;
        uint256 value;
    }

    mapping(uint256 => DelegatedIssue) private _issuances;

    mapping(uint256 => DelegatedRevoke) private _revocations;

    function delegateIssue(
        address operator,
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth burnAuth,
        bytes calldata data
    ) external virtual override onlyMinter(tokenId) {
        if (
            operator == address(0) ||
            to == address(0) ||
            tokenId == 0 ||
            slot == 0
        ) revert NullValue();

        _issuances[tokenId] = DelegatedIssue(
            operator,
            to,
            amount,
            slot,
            burnAuth
        );
        _grantRole(MINTER_ROLE ^ bytes32(tokenId), operator);

        emit DelegateToken(operator, tokenId);

        data;
    }

    function delegateRevoke(
        address operator,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external virtual override onlyBurner(tokenId) {
        if (operator == address(0) || tokenId == 0) revert NullValue();

        _revocations[tokenId] = DelegatedRevoke(operator, amount);
        _grantRole(BURNER_ROLE ^ bytes32(tokenId), operator);

        emit DelegateToken(operator, tokenId);

        data;
    }

    function _issue(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth auth
    ) internal virtual override {
        if (_issuances[tokenId].operator == from) {
            if (!_validateIssuance(tokenId, to, amount, slot, auth))
                revert Unauthorized(from);

            _revokeRole(MINTER_ROLE ^ bytes32(tokenId), from);
            delete _issuances[tokenId];
        }

        super._issue(from, to, tokenId, amount, slot, auth);
    }

    function _revoke(
        address from,
        uint256 tokenId,
        uint256 amount
    ) internal virtual override {
        if (_revocations[tokenId].operator == from) {
            if (!_validateRevocation(tokenId, amount))
                revert Unauthorized(from);

            _revokeRole(BURNER_ROLE ^ bytes32(tokenId), from);
            delete _revocations[tokenId];
        }

        super._revoke(from, tokenId, amount);
    }

    function _issuanceExists(
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return _issuances[tokenId].operator != address(0);
    }

    function _revocationExists(
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return _revocations[tokenId].operator != address(0);
    }

    function _validateIssuance(
        uint256 tokenId,
        address to,
        uint256 amount,
        uint256 slot,
        BurnAuth auth
    ) internal view virtual returns (bool) {
        DelegatedIssue memory issuance = _issuances[tokenId];
        return
            issuance.to == to &&
            issuance.value == amount &&
            issuance.slot == slot &&
            issuance.burnAuth == auth;
    }

    function _validateRevocation(
        uint256 tokenId,
        uint256 amount
    ) internal view virtual returns (bool) {
        DelegatedRevoke memory revocation = _revocations[tokenId];
        return revocation.value == amount;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Delegate).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
