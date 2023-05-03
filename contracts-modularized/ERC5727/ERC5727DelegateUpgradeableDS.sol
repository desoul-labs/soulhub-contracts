// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interfaces/IERC5727DelegateUpgradeable.sol";
import "./ERC5727Core.sol";
import "./ERC5727Storage.sol";

abstract contract ERC5727DelegateUpgradeableDS is
    IERC5727DelegateUpgradeable,
    ERC5727Core
{
    function __ERC5727Delegate_init() internal onlyInitializing {
        __ERC5727Delegate_init_unchained();
    }

    function __ERC5727Delegate_init_unchained() internal onlyInitializing {}

    function delegate(
        address operator,
        uint256 slot
    ) external virtual override onlyAdmin {
        if (operator == address(0) || slot == 0) revert NullValue();
        if (isOperatorFor(operator, slot))
            revert RoleAlreadyGranted(operator, "voter");

        LibERC5727Storage.s()._minterRole[slot][operator] = true;
        emit Delegate(operator, slot);
    }

    function undelegate(
        address operator,
        uint256 slot
    ) external virtual override onlyAdmin {
        if (operator == address(0) || slot == 0) revert NullValue();
        if (!isOperatorFor(operator, slot))
            revert RoleNotGranted(operator, "voter");

        LibERC5727Storage.s()._minterRole[slot][operator] = false;
        emit UnDelegate(operator, slot);
    }

    function isOperatorFor(
        address operator,
        uint256 slot
    ) public view virtual override returns (bool) {
        if (operator == address(0) || slot == 0) revert NullValue();

        return LibERC5727Storage.s()._minterRole[slot][operator];
    }
}
