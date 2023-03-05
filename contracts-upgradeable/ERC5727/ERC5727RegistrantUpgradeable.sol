// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

import "../ERC5727Registry/interfaces/IERC5727RegistryUpgradeable.sol";
import "../ERC173/ERC173Upgradeable.sol";
import "./interfaces/IERC5727RegistrantUpgradeable.sol";
import "./ERC5727Upgradeable.sol";

contract ERC5727RegistrantUpgradeable is
    ERC173Upgradeable,
    ERC5727Upgradeable,
    IERC5727RegistrantUpgradeable
{
    using ERC165CheckerUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet private _registered;

    function __ERC5727Registrant_init(
        string memory name_,
        string memory symbol_,
        address admin_,
        string memory version_
    ) internal onlyInitializing {
        __ERC173_init_unchained();
        __EIP712_init_unchained(name_, version_);
        __ERC721_init_unchained(name_, symbol_);
        __ERC3525_init_unchained(18);
        __ERC5727_init_unchained(admin_);
        __ERC5727Registrant_init_unchained(admin_);
    }

    function __ERC5727Registrant_init_unchained(
        address admin_
    ) internal onlyInitializing {
        _transferOwnership(admin_);
    }

    function register(address registry) public virtual override onlyAdmin {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);
        if (_registered.contains(registry)) revert AlreadyRegistered(registry);

        uint256 entry = IERC5727RegistryUpgradeable(registry).register(
            address(this)
        );
        _registered.add(registry);

        emit Registered(registry, entry);
    }

    function deregister(address registry) public virtual override onlyAdmin {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);
        if (!_registered.contains(registry)) revert NotRegistered(registry);

        uint256 entry = IERC5727RegistryUpgradeable(registry).deregister(
            address(this)
        );
        _registered.remove(registry);

        emit Deregistered(registry, entry);
    }

    function _transferOwnership(address newOwner) internal virtual override {
        super._transferOwnership(newOwner);

        for (uint256 i = 0; i < _registered.length(); ) {
            address registry = _registered.at(i);
            IERC5727RegistryUpgradeable(registry).transferOwnership(
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
        return
            registry.supportsInterface(
                type(IERC5727RegistryUpgradeable).interfaceId
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC173Upgradeable, ERC5727Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727RegistrantUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
