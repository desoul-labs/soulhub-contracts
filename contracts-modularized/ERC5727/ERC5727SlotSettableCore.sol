// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ERC5727EnumerableCore.sol";
import "../ERC5484/interfaces/IERC5484Upgradeable.sol";
import "./ERC5727SlotSettableStorage.sol";
import "../ERC3525/ERC3525Storage.sol";

contract ERC5727SlotSettableCore is ERC5727EnumerableCore {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC5727EnumerableCore) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override(ERC5727EnumerableCore) {
        ERC5727EnumerableCore._beforeValueTransfer(
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
    ) internal virtual override(ERC5727EnumerableCore) {
        ERC5727EnumerableCore._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }
}
