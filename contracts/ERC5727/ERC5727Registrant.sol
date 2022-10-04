// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IERC5727Registrant.sol";
import "../ERC5727Registry/interfaces/IERC5727Registry.sol";
import "./ERC5727.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

abstract contract ERC5727Registrant is ERC5727, IERC5727Registrant {
    using ERC165Checker for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _registered;

    constructor(string memory name, string memory symbol)
        ERC5727(name, symbol)
    {}

    function register(address _registry) public override onlyOwner {
        require(_isRegistry(_registry), "ERC5727Registrant: not a registry");

        bool success = _registered.add(_registry);
        require(success, "ERC5727Registrant: already registered");

        IERC5727Registry registry = IERC5727Registry(_registry);
        registry.register(address(this));

        emit Registered(_registry);
    }

    function deregister(address _registry) public override onlyOwner {
        require(_isRegistry(_registry), "ERC5727Registrant: not a registry");

        bool success = _registered.remove(_registry);
        require(success, "ERC5727Registrant: already registered");

        IERC5727Registry registry = IERC5727Registry(_registry);
        registry.deregister(address(this));

        emit Deregistered(_registry);
    }

    function isRegistered(address _registry) external view returns (bool) {
        return _registered.contains(_registry);
    }

    function transferOwnership(address newOwner) public override {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        require(_isRegistry(_msgSender()), "ERC5727Registrant: not a registry");

        _transferOwnership(newOwner);

        for (uint256 i = 0; i < _registered.length(); i++) {
            address _registry = _registered.at(i);
            deregister(_registry);
            register(_registry);
        }
    }

    function registryTransferOwnership(address newOwner) public {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        require(_isRegistry(_msgSender()), "ERC5727Registrant: not a registry");

        _transferOwnership(newOwner);
    }

    function _isRegistry(address _registry) internal view returns (bool) {
        return _registry.supportsInterface(type(IERC5727Registry).interfaceId);
    }
}
