// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

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
        string _baseUri;
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

library LibERC721PausableStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc721Pausable.storage");

    struct ERC721PausableStorage {
        bool _paused;
    }

    function s() internal pure returns (ERC721PausableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

library LibERC721EnumerableUpgradeableStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.erc721Enumerable.storage");

    struct ERC721EnumerableUpgradeableStorage {
        // Mapping from owner to list of owned token IDs
        mapping(address => EnumerableSetUpgradeable.UintSet) _ownedTokens;
        EnumerableSetUpgradeable.UintSet _allTokens;
        EnumerableSetUpgradeable.AddressSet _allOwners;
    }

    function s()
        internal
        pure
        returns (ERC721EnumerableUpgradeableStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
