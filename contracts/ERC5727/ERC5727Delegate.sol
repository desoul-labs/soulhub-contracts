// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interfaces/IERC5727Delegate.sol";
import "./ERC5727.sol";

abstract contract ERC5727Delegate is IERC5727Delegate, ERC5727 {
    function delegate(
        address operator,
        uint256 slot
    ) external virtual override onlyAdmin {
        if (operator == address(0) || slot == 0) revert NullValue();
        if (isOperatorFor(operator, slot))
            revert RoleAlreadyGranted(operator, MINTER_ROLE ^ bytes32(slot));

        _grantRole(MINTER_ROLE ^ bytes32(slot), operator);
        emit Delegate(operator, slot);
    }

    function unDelegate(
        address operator,
        uint256 slot
    ) external virtual override onlyAdmin {
        if (operator == address(0) || slot == 0) revert NullValue();
        if (!isOperatorFor(operator, slot))
            revert RoleNotGranted(operator, MINTER_ROLE ^ bytes32(slot));

        _revokeRole(MINTER_ROLE ^ bytes32(slot), operator);
        emit UnDelegate(operator, slot);
    }

    function isOperatorFor(
        address operator,
        uint256 slot
    ) public view virtual override returns (bool) {
        if (operator == address(0) || slot == 0) revert NullValue();

        return hasRole(MINTER_ROLE ^ bytes32(slot), operator);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Delegate).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
