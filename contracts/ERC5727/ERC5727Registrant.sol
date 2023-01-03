// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "./interfaces/IERC5727Registrant.sol";
import "../ERC5727Registry/interfaces/IERC5727Registry.sol";
import "./ERC5727.sol";

abstract contract ERC5727Registrant is IERC5727Registrant, ERC5727 {
    using ERC165Checker for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _registered;

    function _register(address registry) internal virtual {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);

        uint256 id = IERC5727Registry(registry).register(address(this));
        _registered.add(registry);

        emit Registered(registry, id);
    }

    function register(address registry) public override onlyAdmin {
        if (_registered.contains(registry)) revert AlreadyRegistered(registry);

        _register(registry);
    }

    function _deregister(address registry) internal virtual {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);

        uint256 id = IERC5727Registry(registry).deregister(address(this));
        _registered.remove(registry);

        emit Deregistered(registry, id);
    }

    function deregister(address registry) public override onlyAdmin {
        if (!_registered.contains(registry)) revert NotRegistered(registry);

        _deregister(registry);
    }

    function isRegistered(address registry) external view returns (bool) {
        return _registered.contains(registry);
    }

    function _isRegistry(address registry) internal view returns (bool) {
        return registry.supportsInterface(type(IERC5727Registry).interfaceId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Registrant).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
