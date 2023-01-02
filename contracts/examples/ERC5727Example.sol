// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../ERC5727/ERC5727Expirable.sol";
import "../ERC5727/ERC5727Governance.sol";
import "../ERC5727/ERC5727Delegate.sol";
import "../ERC5727/ERC5727Shadow.sol";
import "../ERC5727/ERC5727SlotEnumerable.sol";
import "../ERC5727/ERC5727Recovery.sol";

contract ERC5727Example is
    ERC5727Expirable,
    ERC5727Governance,
    ERC5727Delegate,
    ERC5727SlotEnumerable,
    ERC5727Shadow,
    ERC5727Recovery
{
    string private _baseTokenURI;

    struct Slot {
        uint256 maxSupply;
        uint256 tokenCounts;
        uint256[] tokenFees;
        uint256[] tokenValues;
        uint256[] tokenExpiryDates;
        bool[] tokenShadowed;
    }

    mapping(uint256 => Slot) private _slots;

    event SlotAdded(uint256 indexed slot, uint256 maxSupply);

    constructor(
        string memory name,
        string memory symbol,
        address[] memory voters,
        string memory baseTokenURI
    ) ERC5727Governance(name, symbol, voters) {
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            ERC5727Governance,
            ERC5727Delegate,
            ERC5727Expirable,
            ERC5727Recovery,
            ERC5727Shadow,
            ERC5727SlotEnumerable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeView(
        uint256 tokenId
    ) internal view virtual override(ERC5727, ERC5727Shadow) {
        ERC5727Shadow._beforeView(tokenId);
    }

    function createSlot(
        uint256 maxSupply,
        uint256[] calldata values,
        uint256[] calldata expiryDates,
        uint256[] calldata fees,
        bool[] calldata shadowed
    ) external virtual onlyOwner {
        uint256 nextSlot = slotCount();
        _slots[nextSlot] = Slot({
            maxSupply: maxSupply,
            tokenCounts: values.length,
            tokenFees: fees,
            tokenValues: values,
            tokenExpiryDates: expiryDates,
            tokenShadowed: shadowed
        });
        _addSlot(nextSlot);

        emit SlotAdded(nextSlot, maxSupply);
    }

    function collect(uint256 slotId) external payable virtual {
        require(slotId < slotCount(), "ERC5727Example: invalid slot");
        require(
            !isSoulInSlot(_msgSender(), slotId),
            "ERC5727Example: soul already collected"
        );

        Slot storage slot = _slots[slotId];
        require(
            tokenSupplyInSlot(slotId) < slot.maxSupply * slot.tokenCounts,
            "ERC5727Example: slot is full"
        );

        uint256 feeSum = 0;
        for (uint256 i = 0; i < slot.tokenCounts; i++) {
            feeSum += slot.tokenFees[i];
        }
        require(msg.value >= feeSum, "ERC5727Example: insufficient fee");

        for (uint256 i = 0; i < slot.tokenCounts; i++) {
            payable(owner()).transfer(slot.tokenFees[i]);

            uint256 tokenId = _mint(_msgSender(), slot.tokenValues[i], slotId);
            if (slot.tokenShadowed[i]) {
                _shadow(tokenId);
            }
            _setExpiryDate(tokenId, slot.tokenExpiryDates[i]);
        }
    }

    function mint(
        address soul,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) external payable virtual onlyOwner {
        uint256 tokenId = _mint(soul, value, slot);
        if (shadowed) {
            _shadow(tokenId);
        }
        _setExpiryDate(tokenId, expiryDate);
    }

    function revoke(uint256 tokenId) external virtual onlyOwner {
        _revoke(tokenId);
    }

    function mintBatch(
        address[] calldata souls,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) external virtual onlyOwner {
        uint256[] memory tokenIds = _mintBatch(souls, value, slot);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (shadowed) _shadow(tokenIds[i]);
            _setExpiryDate(tokenIds[i], expiryDate);
        }
    }

    function revokeBatch(
        uint256[] calldata tokenIds
    ) external virtual onlyOwner {
        _revokeBatch(tokenIds);
    }

    function _beforeTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    )
        internal
        virtual
        override(ERC5727, ERC5727Enumerable, ERC5727SlotEnumerable)
    {
        ERC5727Enumerable._beforeTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
        ERC5727SlotEnumerable._beforeTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
    }

    function _afterTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._afterTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
    }

    function _afterTokenRevoke(
        uint256 tokenId
    ) internal virtual override(ERC5727, ERC5727Enumerable) {
        ERC5727Enumerable._afterTokenRevoke(tokenId);
    }

    function _beforeTokenDestroy(
        uint256 tokenId
    )
        internal
        virtual
        override(ERC5727, ERC5727Enumerable, ERC5727SlotEnumerable)
    {
        ERC5727Enumerable._beforeTokenDestroy(tokenId);
        ERC5727SlotEnumerable._beforeTokenDestroy(tokenId);
    }

    function valueOf_(uint256 tokenId) external virtual returns (uint256) {
        _beforeView(tokenId);
        return valueOf(tokenId);
    }

    function tokenOf(
        uint256 tokenId
    ) external view virtual returns (Token memory) {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId);
    }

    function slotURI(
        uint256 slot
    )
        public
        view
        virtual
        override(ERC5727, ERC5727SlotEnumerable)
        returns (string memory)
    {
        return ERC5727SlotEnumerable.slotURI(slot);
    }
}
