//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "../ERC721/ERC721EnumerableUpgradeable.sol";
import "./interfaces/IERC3525Upgradeable.sol";
import "./interfaces/IERC3525MetadataUpgradeable.sol";

contract ERC3525Upgradeable is
    IERC3525Upgradeable,
    IERC3525MetadataUpgradeable,
    ERC721EnumerableUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for address;
    using StringsUpgradeable for uint256;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    /// @dev tokenId => values
    mapping(uint256 => uint256) internal _values;

    /// @dev tokenId => operators => allowances
    mapping(uint256 => EnumerableMapUpgradeable.AddressToUintMap)
        private _valueApprovals;

    /// @dev tokenId => slot
    mapping(uint256 => uint256) internal _slots;

    uint8 private _decimals;

    function __ERC3525_init(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
        __ERC3525_init_unchained(decimals_);
    }

    function __ERC3525_init_unchained(
        uint8 decimals_
    ) internal onlyInitializing {
        _decimals = decimals_;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC3525Upgradeable).interfaceId ||
            interfaceId == type(IERC3525MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function valueDecimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function balanceOf(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        _requireMinted(tokenId);

        return _values[tokenId];
    }

    function slotOf(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        _requireMinted(tokenId);

        return _slots[tokenId];
    }

    function contractURI()
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, address(this).toHexString()))
                : "";
    }

    function slotURI(
        uint256 slot
    ) public view virtual override returns (string memory) {
        string memory contractUri = contractURI();
        return
            bytes(contractUri).length > 0
                ? string(
                    abi.encodePacked(contractUri, "/slots/", slot.toString())
                )
                : "";
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, IERC721MetadataUpgradeable)
        returns (string memory)
    {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }

        string memory contractUri = contractURI();
        return
            bytes(contractUri).length > 0
                ? string(
                    abi.encodePacked(
                        contractUri,
                        "/tokens/",
                        tokenId.toString()
                    )
                )
                : "";
    }

    function approve(
        uint256 tokenId,
        address to,
        uint256 value
    ) public payable virtual override {
        approve(to, tokenId);

        if (!ERC721Upgradeable._isApprovedOrOwner(_msgSender(), tokenId))
            revert Unauthorized(_msgSender());

        _approve(tokenId, to, value);
    }

    function allowance(
        uint256 tokenId,
        address operator
    ) public view virtual override returns (uint256) {
        return _valueApprovals[tokenId].get(operator);
    }

    function transferFrom(
        uint256 fromTokenId,
        address to,
        uint256 value
    ) public payable virtual override returns (uint256) {
        _spendAllowance(_msgSender(), fromTokenId, value);

        uint256 newTokenId = _getNewTokenId(fromTokenId);
        _mint(to, newTokenId, _slots[fromTokenId]);
        _transfer(fromTokenId, newTokenId, value);

        return newTokenId;
    }

    function transferFrom(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 value
    ) public payable virtual override {
        _spendAllowance(_msgSender(), fromTokenId, value);

        if (_slots[fromTokenId] != _slots[toTokenId])
            revert Mismatch(_slots[fromTokenId], _slots[toTokenId]);

        _transfer(fromTokenId, toTokenId, value);
    }

    function _mint(address to, uint256 tokenId, uint256 slot) internal virtual {
        if (tokenId == 0 || slot == 0) revert NullValue();

        ERC721Upgradeable._mint(to, tokenId);
        _slots[tokenId] = slot;

        emit SlotChanged(tokenId, 0, slot);
    }

    function _mint(uint256 tokenId, uint256 value) internal virtual {
        _requireMinted(tokenId);

        address owner = ownerOf(tokenId);
        uint256 slot = slotOf(tokenId);

        _beforeValueTransfer(address(0), owner, 0, tokenId, slot, value);

        _values[tokenId] = value;
        emit TransferValue(0, tokenId, value);

        _afterValueTransfer(address(0), owner, 0, tokenId, slot, value);
    }

    function _burn(uint256 tokenId) internal virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        ERC721Upgradeable._burn(tokenId);

        uint256 slot = _slots[tokenId];
        uint256 value = _values[tokenId];

        _beforeValueTransfer(owner, address(0), tokenId, 0, slot, value);

        delete _slots[tokenId];
        delete _values[tokenId];

        _afterValueTransfer(owner, address(0), tokenId, 0, slot, value);

        emit TransferValue(tokenId, 0, value);
        emit SlotChanged(tokenId, slot, 0);
    }

    function _burn(uint256 tokenId, uint256 value) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        uint256 slot = _slots[tokenId];

        if (_values[tokenId] < value)
            revert InsufficientBalance(_values[tokenId], value);

        _beforeValueTransfer(owner, address(0), tokenId, 0, slot, value);

        delete _valueApprovals[tokenId];

        _values[tokenId] -= value;

        _afterValueTransfer(owner, address(0), tokenId, 0, slot, value);

        emit TransferValue(tokenId, 0, value);
    }

    function _transfer(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 value
    ) internal virtual {
        address from = ERC721Upgradeable.ownerOf(fromTokenId);
        address to = ERC721Upgradeable.ownerOf(toTokenId);
        uint256 slot = _slots[fromTokenId];

        _beforeValueTransfer(from, to, fromTokenId, toTokenId, slot, value);

        delete _valueApprovals[fromTokenId];

        _values[fromTokenId] -= value;
        _values[toTokenId] += value;

        _afterValueTransfer(from, to, fromTokenId, toTokenId, slot, value);

        emit TransferValue(fromTokenId, toTokenId, value);
    }

    function _spendAllowance(
        address operator,
        uint256 tokenId,
        uint256 value
    ) internal virtual {
        if (ownerOf(tokenId) == operator) return;
        uint256 currentAllowance = ERC3525Upgradeable.allowance(
            tokenId,
            operator
        );
        if (
            !_isApprovedOrOwner(operator, tokenId) &&
            currentAllowance != type(uint256).max
        ) {
            if (currentAllowance < value)
                revert InsufficientBalance(currentAllowance, value);

            _approve(tokenId, operator, currentAllowance - value);
        }
    }

    function _approve(
        uint256 tokenId,
        address to,
        uint256 value
    ) internal virtual {
        _valueApprovals[tokenId].set(to, value);

        emit ApprovalValue(tokenId, to, value);
    }

    function _getNewTokenId(
        uint256 fromTokenId
    ) internal virtual returns (uint256) {
        fromTokenId;

        return ERC721EnumerableUpgradeable.totalSupply() + 1;
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual {
        from;
        to;
        fromTokenId;
        toTokenId;
        slot;
        value;
    }

    function _afterValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual {
        from;
        to;
        fromTokenId;
        toTokenId;
        slot;
        value;
    }
}
