//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./IERC5342.sol";
import "./IERC5342Metadata.sol";
import "./IERC5342Enumerable.sol";

abstract contract ERC5342 is
    IERC5342Metadata,
    IERC5342Enumerable,
    ERC165,
    Ownable,
    AccessControlEnumerable
{
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Token {
        address issuer;
        address soul;
        bool valid;
        uint256 value;
        uint256 slot;
    }

    mapping(uint256 => Token) private _tokens;
    mapping(address => EnumerableSet.UintSet) private _indexedTokenIds;
    mapping(address => uint256) private _numberOfValidTokens;

    string private _name;
    string private _symbol;

    Counters.Counter private _emittedCount;
    Counters.Counter private _soulsCount;

    constructor(string memory name_, string memory symbol_) Ownable() {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165, AccessControlEnumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5342).interfaceId ||
            interfaceId == type(IERC5342Metadata).interfaceId ||
            interfaceId == type(IERC5342Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _getTokenOrRevert(uint256 tokenId)
        internal
        view
        virtual
        returns (Token storage)
    {
        Token storage token = _tokens[tokenId];
        require(token.soul != address(0), "ERC5342: Token does not exist");
        return token;
    }

    function _mintUnsafe(
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal {
        _mintUnsafe(_msgSender(), soul, tokenId, value, slot, valid);
    }

    function _mintUnsafe(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal {
        require(
            _tokens[tokenId].soul == address(0),
            "ERC5342: Cannot mint an assigned token"
        );
        require(value != 0, "ERC5342: Cannot mint zero value");
        if (EnumerableSet.length(_indexedTokenIds[soul]) == 0) {
            Counters.increment(_soulsCount);
        }
        _tokens[tokenId] = Token(issuer, soul, valid, value, slot);
        EnumerableSet.add(_indexedTokenIds[soul], tokenId);
        if (valid) {
            _numberOfValidTokens[soul] += 1;
        }
        emit SlotChanged(tokenId, 0, slot);
    }

    function _mint(
        address soul,
        uint256 value,
        uint256 slot
    ) internal virtual returns (uint256 tokenId) {
        tokenId = Counters.current(_emittedCount);
        _mintUnsafe(soul, tokenId, value, slot, true);
        emit Minted(soul, tokenId, value);
        Counters.increment(_emittedCount);
    }

    function _mintBatch(
        address soul,
        uint256[] memory values,
        uint256 slot
    ) internal virtual returns (uint256[] memory tokenId) {
        for (uint256 i = 0; i < values.length; i++) {
            tokenId[i] = _mint(soul, values[i], slot);
        }
    }

    function _charge(uint256 tokenId, uint256 value) internal virtual {
        _getTokenOrRevert(tokenId).value += value;
        emit Charged(tokenId, value);
    }

    function _chargeBatch(uint256[] memory tokenIds, uint256[] memory values)
        internal
        virtual
    {
        require(
            tokenIds.length == values.length,
            "ERC5342: unmatched size of tokenIds and values"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _charge(tokenIds[i], values[i]);
        }
    }

    function _consume(uint256 tokenId, uint256 value) internal virtual {
        require(
            _getTokenOrRevert(tokenId).value > value,
            "ERC5342: not enough balance"
        );
        _getTokenOrRevert(tokenId).value -= value;
        emit Consumed(tokenId, value);
    }

    function _consumeBatch(uint256[] memory tokenIds, uint256[] memory values)
        internal
        virtual
    {
        require(
            tokenIds.length == values.length,
            "ERC5342: unmatched size of tokenIds and values"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _consume(tokenIds[i], values[i]);
        }
    }

    function _revoke(uint256 tokenId) internal virtual {
        require(
            _getTokenOrRevert(tokenId).valid,
            "ERC5342: Token is already invalid"
        );
        _tokens[tokenId].valid = false;
        assert(_numberOfValidTokens[_tokens[tokenId].soul] > 0);
        _numberOfValidTokens[_tokens[tokenId].soul] -= 1;
        emit Revoked(_tokens[tokenId].soul, tokenId);
    }

    function _revokeBatch(uint256[] memory tokenIds) internal virtual {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _revoke(tokenIds[i]);
        }
    }

    function _destroy(uint256 tokenId) internal virtual {
        address soul = soulOf(tokenId);
        uint256 slot = slotOf(tokenId);
        uint256 value = valueOf(tokenId);

        if (_tokens[tokenId].valid) {
            assert(_numberOfValidTokens[soul] > 0);
            _numberOfValidTokens[soul] -= 1;
        }
        delete _tokens[tokenId];
        EnumerableSet.remove(_indexedTokenIds[soul], tokenId);
        if (EnumerableSet.length(_indexedTokenIds[soul]) == 0) {
            assert(Counters.current(_soulsCount) > 0);
            Counters.decrement(_soulsCount);
        }

        emit Consumed(tokenId, value);
        emit Destroyed(soul, tokenId);
        emit SlotChanged(tokenId, slot, 0);
    }

    function _isCreator() internal view virtual returns (bool) {
        return _msgSender() == owner();
    }

    function _increaseEmittedCount() internal {
        Counters.increment(_emittedCount);
    }

    function _tokensOfSoul(address soul)
        internal
        view
        returns (uint256[] memory tokenIds)
    {
        tokenIds = EnumerableSet.values(_indexedTokenIds[soul]);
        require(tokenIds.length != 0, "ERC5342: the soul has no token");
    }

    function _beforeView(uint256 tokenId) internal view virtual {}

    function soulOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).soul;
    }

    function valueOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).value;
    }

    function slotOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).slot;
    }

    function issuerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).issuer;
    }

    function isValid(uint256 tokenId)
        public
        view
        virtual
        override
        returns (bool)
    {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).valid;
    }

    function emittedCount() public view virtual override returns (uint256) {
        return Counters.current(_emittedCount);
    }

    function soulsCount() public view virtual override returns (uint256) {
        return Counters.current(_soulsCount);
    }

    function balanceOf(address soul)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return EnumerableSet.length(_indexedTokenIds[soul]);
    }

    function hasValid(address soul)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _numberOfValidTokens[soul] > 0;
    }

    function tokenOfSoulByIndex(address soul, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        EnumerableSet.UintSet storage ids = _indexedTokenIds[soul];
        require(
            index < EnumerableSet.length(ids),
            "ERC5342: Token does not exist"
        );
        return EnumerableSet.at(ids, index);
    }

    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return index;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
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
                ? string(
                    abi.encodePacked(
                        baseURI,
                        "contract/",
                        Strings.toHexString(uint256(uint160(address(this))))
                    )
                )
                : "";
    }

    function slotURI(uint256 slot)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, "slot/", slot.toString()))
                : "";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _getTokenOrRevert(tokenId);
        bytes memory baseURI = bytes(_baseURI());
        if (baseURI.length > 0) {
            return
                string(
                    abi.encodePacked(baseURI, Strings.toHexString(tokenId, 32))
                );
        }
        return "";
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
}
