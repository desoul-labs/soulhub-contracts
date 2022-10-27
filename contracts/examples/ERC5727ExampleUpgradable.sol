// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC5727Upgradeable/ERC5727ExpirableUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727GovernanceUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727DelegateUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727ShadowUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727SlotEnumerableUpgradeable.sol";
import "../ERC5727Upgradeable/ERC5727RecoveryUpgradeable.sol";

contract ERC5727ExampleUpgradeable is
    ERC5727ExpirableUpgradeable,
    ERC5727GovernanceUpgradeable,
    ERC5727DelegateUpgradeable,
    ERC5727SlotEnumerableUpgradeable,
    ERC5727ShadowUpgradeable,
    ERC5727RecoveryUpgradeable
{
    string private _baseTokenURI;

    function __ERC5727Example_init_unchained(string memory baseTokenURI)
        internal
        onlyInitializing
    {
        _baseTokenURI = baseTokenURI;
    }

    function __ERC5727Example_init(
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
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            ERC5727GovernanceUpgradeable,
            ERC5727DelegateUpgradeable,
            ERC5727ExpirableUpgradeable,
            ERC5727RecoveryUpgradeable,
            ERC5727ShadowUpgradeable,
            ERC5727SlotEnumerableUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeView(uint256 tokenId)
        internal
        view
        virtual
        override(ERC5727Upgradeable, ERC5727ShadowUpgradeable)
    {
        ERC5727ShadowUpgradeable._beforeView(tokenId);
    }

    function mint(
        address soul,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) public virtual onlyOwner {
        uint256 tokenId = _mint(soul, value, slot);
        if (shadowed) {
            _shadow(tokenId);
        }
        _setExpiryDate(tokenId, expiryDate);
    }

    function revoke(uint256 tokenId) public virtual onlyOwner {
        _revoke(tokenId);
    }

    function mintBatch(
        address[] memory souls,
        uint256 value,
        uint256 slot,
        uint256 expiryDate,
        bool shadowed
    ) public virtual onlyOwner {
        uint256[] memory tokenIds = _mintBatch(souls, value, slot);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (shadowed) _shadow(tokenIds[i]);
            _setExpiryDate(tokenIds[i], expiryDate);
        }
    }

    function revokeBatch(uint256[] memory tokenIds) public virtual onlyOwner {
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

    function _afterTokenRevoke(uint256 tokenId)
        internal
        virtual
        override(ERC5727Upgradeable, ERC5727EnumerableUpgradeable)
    {
        ERC5727EnumerableUpgradeable._afterTokenRevoke(tokenId);
    }

    function _beforeTokenDestroy(uint256 tokenId)
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

    function valueOf_(uint256 tokenId) public virtual returns (uint256) {
        return valueOf(tokenId);
    }
}
