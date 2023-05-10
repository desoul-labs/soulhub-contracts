// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../ERC5727/ERC5727ExpirableUpgradeable.sol";
import "../ERC5727/ERC5727GovernanceUpgradeable.sol";
import "../ERC5727/ERC5727DelegateUpgradeable.sol";
import "../ERC5727/ERC5727RecoveryUpgradeable.sol";
import "../ERC5727/ERC5727ClaimableUpgradeable.sol";

contract ERC5727SBTUpgradeable is
    ERC5727ClaimableUpgradeable,
    ERC5727RecoveryUpgradeable,
    ERC5727ExpirableUpgradeable,
    ERC5727GovernanceUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    string private _baseUri;
    // slot -> max supply
    mapping(uint256 => uint256) private _maxSupply;
    // slot -> period
    mapping(uint256 => uint64) private _expiration;
    // slot -> burnAuth
    mapping(uint256 => BurnAuth) private _burnAuth;

    function __ERC5727SBT_init(
        string memory name_,
        string memory symbol_,
        address admin_,
        string memory baseURI_,
        string memory version_
    ) public initializer {
        __EIP712_init_unchained(name_, version_);
        __ERC721_init_unchained(name_, symbol_);
        __ERC3525_init_unchained(18);
        __ERC5727_init_unchained(admin_);
        __ERC5727Governance_init_unchained(admin_);
        __ERC5727SBT_init_unchained(baseURI_);
    }

    function __ERC5727SBT_init_unchained(
        string memory baseURI_
    ) internal onlyInitializing {
        _baseUri = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseUri;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    )
        internal
        virtual
        override(ERC5727Upgradeable, ERC5727EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    )
        internal
        virtual
        override(ERC5727Upgradeable, ERC5727EnumerableUpgradeable)
    {
        if (from == address(0)) {
            if (
                _maxSupply[slot] != 0 &&
                tokenSupplyInSlot(slot) + 1 > _maxSupply[slot]
            ) revert ExceedsMaxSupply(_maxSupply[slot]);
            if (ownerBalanceInSlot(to, slot) > 0) {
                revert Forbidden();
            }
        }
        ERC5727EnumerableUpgradeable._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }

    function _afterValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    )
        internal
        virtual
        override(ERC3525Upgradeable, ERC5727EnumerableUpgradeable)
    {
        ERC5727EnumerableUpgradeable._afterValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }

    function setupSlot(
        BurnAuth burnAuth,
        uint256 maxSupply
    ) external onlyAdmin {
        uint256 slot = slotCount() + 1;
        _maxSupply[slot] = maxSupply;
        _burnAuth[slot] = burnAuth;

        _allSlots.add(slot);
    }

    function getMaxSupply(uint256 slot) external view returns (uint256) {
        return _maxSupply[slot];
    }

    function batchIssue(
        address[] calldata to,
        uint256 slot,
        string calldata uri,
        bytes calldata data
    ) external virtual onlyAdmin {
        uint256 next = totalSupply() + 1;
        for (uint256 i = 0; i < to.length; i++) {
            issue(to[i], next + i, slot, _burnAuth[slot], address(this), data);
            _setTokenURI(next + i, uri);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            ERC5727GovernanceUpgradeable,
            ERC5727ExpirableUpgradeable,
            ERC5727RecoveryUpgradeable,
            ERC5727ClaimableUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
