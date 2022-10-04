// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC5727Registry.sol";

interface IERC5727RegistryMetadata is IERC5727Registry {
    function registryURI() external view returns (string memory);
}
