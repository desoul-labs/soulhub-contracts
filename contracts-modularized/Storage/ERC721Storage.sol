// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

library LibERC721Storage {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc721.storage");

    struct ERC721Storage {
        // Optional mapping for token URIs
        mapping(uint256 => string) _tokenURIs;
        // Token name
        string _name;
        // Token symbol
        string _symbol;
        // Mapping from token ID to owner address
        mapping(uint256 => address) _owners;
        // Mapping owner address to token count
        mapping(address => uint256) _balances;
        // Mapping from token ID to approved address
        mapping(uint256 => address) _tokenApprovals;
        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;
    }

    function s() internal pure returns (ERC721Storage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
