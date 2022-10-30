// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IERC5727RegistrantUpgradeable.sol";
import "../ERC5727Registry/interfaces/IERC5727Registry.sol";
import "./ERC5727Upgradeable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

abstract contract ERC5727RegistrantUpgradeable is
    ERC5727Upgradeable,
    IERC5727RegistrantUpgradeable
{
    using ERC165Checker for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet private _registered;

    function __ERC5727Registrant_init_unchained() internal onlyInitializing {}

    function __ERC5727Registrant_init() internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        __ERC5727Registrant_init_unchained();
    }

    function _register(address _registry) internal returns (uint256) {
        require(_isRegistry(_registry), "ERC5727Registrant: not a registry");

        IERC5727Registry registry = IERC5727Registry(_registry);
        uint256 id = registry.register(address(this));

        emit Registered(_registry);

        return id;
    }

    function register(address _registry)
        public
        override
        onlyOwner
        returns (uint256)
    {
        require(
            !_registered.contains(_registry),
            "ERC5727Registrant: already registered"
        );
        uint256 id = _register(_registry);

        bool success = _registered.add(_registry);
        require(success, "ERC5727Registrant: failed to register");

        return id;
    }

    function _deregister(address _registry) internal returns (uint256) {
        require(_isRegistry(_registry), "ERC5727Registrant: not a registry");

        IERC5727Registry registry = IERC5727Registry(_registry);
        uint256 id = registry.deregister(address(this));

        emit Deregistered(_registry);

        return id;
    }

    function deregister(address _registry)
        public
        override
        onlyOwner
        returns (uint256)
    {
        require(
            _registered.contains(_registry),
            "ERC5727Registrant: not registered"
        );
        uint256 id = _deregister(_registry);

        bool success = _registered.remove(_registry);
        require(success, "ERC5727Registrant: failed to deregister");

        return id;
    }

    function isRegistered(address _registry) external view returns (bool) {
        return _registered.contains(_registry);
    }

    function transferOwnership(address newOwner) public virtual override {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        for (uint256 i = 0; i < _registered.length(); i++) {
            address _registry = _registered.at(i);
            _deregister(_registry);
        }

        _transferOwnership(newOwner);

        for (uint256 i = 0; i < _registered.length(); i++) {
            address _registry = _registered.at(i);
            _register(_registry);
        }
    }

    function _isRegistry(address _registry) internal view returns (bool) {
        return _registry.supportsInterface(type(IERC5727Registry).interfaceId);
    }
}
