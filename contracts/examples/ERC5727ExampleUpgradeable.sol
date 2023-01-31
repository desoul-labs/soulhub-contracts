// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../ERC5727Upgradeable/ERC5727ExpirableUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727GovernanceUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727DelegateUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727ShadowUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727SlotEnumerableUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727RecoveryUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727RegistrantUpgradeable.sol";

contract ERC5727ExampleUpgradeable is
    ERC5727ExpirableUpgradeable,
    ERC5727GovernanceUpgradeable,
    ERC5727DelegateUpgradeable,
    ERC5727SlotEnumerableUpgradeable,
    ERC5727RecoveryUpgradeable,
    ERC5727RegistrantUpgradeable
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

    function __ERC5727Example_init_unchained(
        string memory baseTokenURI
    ) internal onlyInitializing {
        _baseTokenURI = baseTokenURI;
    }

    function __ERC5727Example_init(
        address owner,
        string memory name,
        string memory symbol,
        address[] memory voters,
        string memory baseTokenURI
    ) public initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControlEnumerable_init_unchained();
        __Ownable_init_unchained();
        __ERC5727_init_unchained(name, symbol);
        __ERC5727Governance_init_unchained(voters);
        __ERC5727Example_init_unchained(baseTokenURI);
        _transferOwnership(owner);
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
            ERC5727GovernanceUpgradeable,
            ERC5727DelegateUpgradeable,
            ERC5727ExpirableUpgradeable,
            ERC5727RecoveryUpgradeable,
            ERC5727SlotEnumerableUpgradeable,
            ERC5727RegistrantUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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
            _setExpiryDate(tokenId, slot.tokenExpiryDates[i]);
        }
    }

    function mint(
        address soul,
        uint256 value,
        uint256 slot,
        uint256 expiryDate
    ) external payable virtual onlyOwner {
        uint256 tokenId = _mint(soul, value, slot);
        _setExpiryDate(tokenId, expiryDate);
    }

    function revoke(uint256 tokenId) external virtual onlyOwner {
        _revoke(tokenId);
    }

    function mintBatch(
        address[] calldata souls,
        uint256 values,
        uint256 slots,
        uint256 expiryDate
    ) external payable virtual onlyOwner {
        uint256[] memory tokenIds = _mintBatch(souls, values, slots);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setExpiryDate(tokenIds[i], expiryDate);
        }
    }

    function revokeBatch(uint256[] memory tokenIds) external virtual onlyOwner {
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
        override(
            ERC5727Upgradeable,
            ERC5727EnumerableUpgradeable,
            ERC5727SlotEnumerableUpgradeable
        )
    {
        ERC5727EnumerableUpgradeable._beforeTokenMint(
            issuer,
            soul,
            tokenId,
            value,
            slot,
            valid
        );
        ERC5727SlotEnumerableUpgradeable._beforeTokenMint(
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
    )
        internal
        virtual
        override(ERC5727Upgradeable, ERC5727EnumerableUpgradeable)
    {
        ERC5727EnumerableUpgradeable._afterTokenMint(
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
    )
        internal
        virtual
        override(ERC5727Upgradeable, ERC5727EnumerableUpgradeable)
    {
        ERC5727EnumerableUpgradeable._afterTokenRevoke(tokenId);
    }

    function _beforeTokenDestroy(
        uint256 tokenId
    )
        internal
        virtual
        override(
            ERC5727Upgradeable,
            ERC5727EnumerableUpgradeable,
            ERC5727SlotEnumerableUpgradeable
        )
    {
        ERC5727EnumerableUpgradeable._beforeTokenDestroy(tokenId);
        ERC5727SlotEnumerableUpgradeable._beforeTokenDestroy(tokenId);
    }

    function transferOwnership(
        address newOwner
    )
        public
        virtual
        override(ERC5727RegistrantUpgradeable, OwnableUpgradeable)
        onlyOwner
    {
        ERC5727RegistrantUpgradeable.transferOwnership(newOwner);
    }

    function valueOf_(uint256 tokenId) external view virtual returns (uint256) {
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
        override(ERC5727Upgradeable, ERC5727SlotEnumerableUpgradeable)
        returns (string memory)
    {
        return ERC5727SlotEnumerableUpgradeable.slotURI(slot);
    }
}
