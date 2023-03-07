// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../ERC173/ERC173Upgradeable.sol";
import "./interfaces/IERC5727RegistrantUpgradeable.sol";
import "./ERC5727Upgradeable.sol";

abstract contract ERC5727RegistrantUpgradeable is
    ERC173Upgradeable,
    ERC5727Upgradeable,
    IERC5727RegistrantUpgradeable
{
    using ERC165CheckerUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    EnumerableSetUpgradeable.AddressSet private _registered;

    function __ERC5727Registrant_init(
        address admin_
    ) internal onlyInitializing {
        __ERC5727Registrant_init_unchained(admin_);
    }

    function __ERC5727Registrant_init_unchained(
        address admin_
    ) internal onlyInitializing {}

    function register(address registry) public virtual override onlyAdmin {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);
        if (_registered.contains(registry)) revert AlreadyRegistered(registry);

        bytes memory result = registry.functionCall(
            abi.encodeWithSignature("register(address)", address(this))
        );
        uint256 entry = abi.decode(result, (uint256));
        _registered.add(registry);

        emit Registered(registry, entry);
    }

    function deregister(address registry) public virtual override onlyAdmin {
        if (!_isRegistry(registry)) revert InvalidRegistry(registry);
        if (!_registered.contains(registry)) revert NotRegistered(registry);

        bytes memory result = registry.functionCall(
            abi.encodeWithSignature("deregister(address)", address(this))
        );
        uint256 entry = abi.decode(result, (uint256));

        emit Deregistered(registry, entry);
    }

    function _transferOwnership(address newOwner) internal virtual override {
        super._transferOwnership(newOwner);

        for (uint256 i = 0; i < _registered.length(); ) {
            address registry = _registered.at(i);
            registry.functionCall(
                abi.encodeWithSignature(
                    "transferOwnership(address,address)",
                    address(this),
                    newOwner
                )
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
        return registry.supportsInterface(0xaba3b7c3);
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
