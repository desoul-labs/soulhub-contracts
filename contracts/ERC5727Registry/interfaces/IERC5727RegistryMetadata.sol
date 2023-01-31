// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./IERC5727Registry.sol";

interface IERC5727RegistryMetadata is IERC5727Registry {
    function registryURI() external view returns (string memory);
}
