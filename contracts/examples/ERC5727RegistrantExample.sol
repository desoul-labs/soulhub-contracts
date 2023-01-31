// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// import "../ERC5727/ERC5727.sol";
// import "../ERC5727/ERC5727Registrant.sol";
// import "../examples/ERC5727RegistryExample.sol";

// contract ERC5727RegistrantExample is ERC5727Registrant {
//     using EnumerableSet for EnumerableSet.AddressSet;

//     constructor(
//         string memory name,
//         string memory symbol
//     ) ERC5727Registrant(name, symbol) {}

//     function transferOwnership(
//         address newOwner
//     ) public virtual override onlyAdmin {
//         require(
//             newOwner != address(0),
//             "Ownable: new owner is the zero address"
//         );

//         for (uint256 i = 0; i < _registered.length(); i++) {
//             address registryAddr = _registered.at(i);
//             ERC5727RegistryExample registry = ERC5727RegistryExample(
//                 registryAddr
//             );
//             uint256 id = registry.idOf(address(this));
//             registry.transferFrom(owner(), newOwner, id);
//         }

//         _transferOwnership(newOwner);
//     }
// }
