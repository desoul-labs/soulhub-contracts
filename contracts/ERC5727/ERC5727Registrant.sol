// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../ERC5727Registry/interfaces/IERC5727Registry.sol";
import "../ERC173/ERC173.sol";
import "./interfaces/IERC5727Registrant.sol";
import "./ERC5727.sol";

contract ERC5727Registrant is ERC173, ERC5727, IERC5727Registrant {
    using ERC165Checker for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _registered;

    constructor(
        string memory name_,
        string memory symbol_,
        address admin_,
        string memory version_
    ) ERC5727(name_, symbol_, admin_, version_) ERC173() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function register(address registry) public virtual override onlyAdmin {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);
        if (_registered.contains(registry)) revert AlreadyRegistered(registry);

        uint256 entry = IERC5727Registry(registry).register(address(this));
        _registered.add(registry);

        emit Registered(registry, entry);
    }

    function deregister(address registry) public virtual override onlyAdmin {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);
        if (!_registered.contains(registry)) revert NotRegistered(registry);

        uint256 entry = IERC5727Registry(registry).deregister(address(this));
        _registered.remove(registry);

        emit Deregistered(registry, entry);
    }

    function _transferOwnership(address newOwner) internal virtual override {
        super._transferOwnership(newOwner);

        for (uint256 i = 0; i < _registered.length(); ) {
            address registry = _registered.at(i);
            IERC5727Registry(registry).transferOwnership(
                address(this),
                newOwner
            );
            unchecked {
                i++;
            }
        }
    }

    function isRegistered(
        address registry
    ) external view virtual returns (bool) {
        return _registered.contains(registry);
    }

    function _isRegistry(
        address registry
    ) internal view virtual returns (bool) {
        return registry.supportsInterface(type(IERC5727Registry).interfaceId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC173, ERC5727) returns (bool) {
        return
            interfaceId == type(IERC5727Registrant).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
