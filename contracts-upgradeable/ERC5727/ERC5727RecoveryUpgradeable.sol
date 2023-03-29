// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

import "./ERC5727EnumerableUpgradeable.sol";
import "./interfaces/IERC5727RecoveryUpgradeable.sol";

abstract contract ERC5727RecoveryUpgradeable is
    IERC5727RecoveryUpgradeable,
    ERC5727EnumerableUpgradeable
{
    using ECDSAUpgradeable for bytes32;

    bytes32 private constant _RECOVERY_TYPEHASH =
        keccak256("Recovery(address from,address recipient)");

    function __ERC5727Recovery_init() internal onlyInitializing {
        __ERC5727Recovery_init_unchained();
    }

    function __ERC5727Recovery_init_unchained() internal onlyInitializing {}

    function recover(
        address from,
        bytes memory signature
    ) public virtual override {
        if (from == address(0)) revert NullValue();
        address recipient = _msgSender();
        if (from == recipient) revert MethodNotAllowed(recipient);

        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encodePacked(_RECOVERY_TYPEHASH, from, recipient))
        );
        if (digest.recover(signature) != from) revert Forbidden();

        uint256 balance = balanceOf(from);
        for (uint256 i = 0; i < balance; ) {
            uint256 tokenId = tokenOfOwnerByIndex(from, i);

            _unlocked[tokenId] = true;
            _transfer(from, recipient, tokenId);
            _unlocked[tokenId] = false;

            unchecked {
                i++;
            }
        }

        emit Recovered(from, recipient);
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
