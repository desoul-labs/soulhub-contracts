//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../../ERC3525/interfaces/IERC3525MetadataUpgradeable.sol";
import "./IERC5727Upgradeable.sol";

/**
 * @title ERC5727 Soulbound Token Metadata Interface
 * @dev This extension allows querying the metadata of soulbound tokens.
 */
interface IERC5727MetadataUpgradeable is
    IERC3525MetadataUpgradeable,
    IERC5727Upgradeable
{

}
