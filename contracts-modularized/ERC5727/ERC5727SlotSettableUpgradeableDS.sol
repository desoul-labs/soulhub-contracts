// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727EnumerableUpgradeableDS.sol";
import "../ERC5484/interfaces/IERC5484Upgradeable.sol";
import "./ERC5727SlotSettableStorage.sol";
import "../ERC3525/ERC3525Storage.sol";

contract ERC5727SlotSettableUpgradeableDS is ERC5727EnumerableUpgradeableDS {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    function init(
        string memory name_,
        string memory symbol_,
        address admin_,
        string memory baseUri_,
        string memory version_
    ) external virtual override initializer {
        __EIP712_init_unchained(name_, version_);
        __ERC721_init_unchained(name_, symbol_, baseUri_);
        __ERC3525_init_unchained(18);
        __ERC5727_init_unchained(admin_);
        __ERC5727Enumerable_init_unchained();
        __ERC5727SlotSettable_init_unchained();
    }

    function __ERC5727SlotSettable_init_unchained() internal onlyInitializing {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC5727EnumerableUpgradeableDS) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override(ERC5727EnumerableUpgradeableDS) {
        ERC5727EnumerableUpgradeableDS._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
        if (from == address(0)) {
            if (
                LibERC5727SlotSettableStorage.s()._maxSupply[slot] != 0 &&
                tokenSupplyInSlot(slot) + 1 >
                LibERC5727SlotSettableStorage.s()._maxSupply[slot]
            )
                revert ExceedsMaxSupply(
                    LibERC5727SlotSettableStorage.s()._maxSupply[slot]
                );
        }
    }

    function _afterValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override(ERC5727EnumerableUpgradeableDS) {
        ERC5727EnumerableUpgradeableDS._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }

    function setupSlot(
        IERC5484Upgradeable.BurnAuth burnAuth,
        uint256 maxSupply
    ) external onlyAdmin {
        uint256 slot = slotCount() + 1;
        LibERC5727SlotSettableStorage.s()._maxSupply[slot] = maxSupply;
        LibERC5727SlotSettableStorage.s()._burnAuth[slot] = burnAuth;

        LibERC3525SlotEnumerableStorage.s()._allSlots.add(slot);
    }

    function getMaxSupply(uint256 slot) external view returns (uint256) {
        return LibERC5727SlotSettableStorage.s()._maxSupply[slot];
    }

    function batchIssue(
        address[] calldata to,
        uint256 slot,
        string calldata uri,
        bytes calldata data
    ) external virtual onlyAdmin {
        uint256 next = totalSupply() + 1;
        for (uint256 i = 0; i < to.length; i++) {
            issue(
                to[i],
                next + i,
                slot,
                LibERC5727SlotSettableStorage.s()._burnAuth[slot],
                address(this),
                data
            );
            _setTokenURI(next + i, uri);
        }
    }
}
