// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

import "./ERC5727Upgradeable.sol";
import "./interfaces/IERC5727RecoveryUpgradeable.sol";
import "./ERC5727EnumerableUpgradeable.sol";

abstract contract ERC5727RecoveryUpgradeable is
    ERC5727EnumerableUpgradeable,
    IERC5727RecoveryUpgradeable
{
    using ECDSAUpgradeable for bytes32;

    function __ERC5727Recovery_init_unchained() internal onlyInitializing {}

    function __ERC5727Recovery_init() internal onlyInitializing {
        ContextUpgradeable.__Context_init_unchained();
        ERC165Upgradeable.__ERC165_init_unchained();
        AccessControlEnumerableUpgradeable
            .__AccessControlEnumerable_init_unchained();
        OwnableUpgradeable.__Ownable_init_unchained();
        __ERC5727Recovery_init_unchained();
    }

    function recover(
        address soul,
        bytes memory signature
    ) public virtual override {
        address recipient = msg.sender;
        bytes32 messageHash = keccak256(abi.encodePacked(soul, recipient));
        bytes32 signedHash = messageHash.toEthSignedMessageHash();
        require(signedHash.recover(signature) == soul, "Invalid signature");
        uint256[] memory tokenIds = _tokensOfSoul(soul);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            Token storage token = _getTokenOrRevert(tokenIds[i]);
            address issuer = token.issuer;
            uint256 value = token.value;
            uint256 slot = token.slot;
            bool valid = token.valid;
            _destroy(tokenIds[i]);
            _mintUnsafe(issuer, soul, tokenIds[i], value, slot, valid);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC5727EnumerableUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727RecoveryUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
