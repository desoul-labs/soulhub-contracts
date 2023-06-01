// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (metatx/ERC2771Context.sol)

pragma solidity ^0.8.9;

import "../utils/ContextUpgradeable.sol";
import "./Initializable.sol";

bytes32 constant ERC2771_POSITION = keccak256("diamond.initializable.storage");

struct ERC2771Struct {
    address _trustedForwarder;
}

function erc2771ds() pure returns (ERC2771Struct storage erc2771Struct) {
    bytes32 position = ERC2771_POSITION;
    assembly {
        erc2771Struct.slot := position
    }
}

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771ContextUpgradeable is
    Initializable,
    ContextUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable

    /// @custom:oz-upgrades-unsafe-allow constructor
    function __ERC2771ContextUpgradeable_init_unchained(
        address trustedForwarder
    ) internal onlyInitializing {
        erc2771ds()._trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(
        address forwarder
    ) public view virtual returns (bool) {
        return forwarder == erc2771ds()._trustedForwarder;
    }

    function _msgSender()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData()
        internal
        view
        virtual
        override
        returns (bytes calldata)
    {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
