//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IERC5727.sol";
import "./interfaces/IERC5727Metadata.sol";
import "../ERC3525/IERC3525Metadata.sol";

abstract contract ERC5727 is
    IERC5727Metadata,
    ERC165,
    Ownable,
    AccessControlEnumerable
{
    using Address for address;
    using Strings for uint256;
    using Strings for address;

    struct Token {
        address issuer;
        address soul;
        bool valid;
        uint256 value;
        uint256 slot;
    }

    mapping(uint256 => Token) private _tokens;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) Ownable() {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC165, IERC165, AccessControlEnumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727).interfaceId ||
            interfaceId == type(IERC5727Metadata).interfaceId ||
            interfaceId == type(IERC3525Metadata).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _getTokenOrRevert(
        uint256 tokenId
    ) internal view virtual returns (Token storage) {
        Token storage token = _tokens[tokenId];
        require(token.soul != address(0), "ERC5727: Token does not exist");
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
            "ERC5727: Cannot mint an assigned token"
        );
        require(value != 0, "ERC5727: Cannot mint zero value");
        _beforeTokenMint(issuer, soul, tokenId, value, slot, valid);
        _tokens[tokenId] = Token(issuer, soul, valid, value, slot);
        _afterTokenMint(issuer, soul, tokenId, value, slot, valid);
        emit Minted(soul, tokenId, value);
        emit SlotChanged(tokenId, 0, slot);
    }

    function _charge(uint256 tokenId, uint256 value) internal virtual {
        _getTokenOrRevert(tokenId).value += value;
        emit Charged(tokenId, value);
    }

    function _chargeBatch(
        uint256[] memory tokenIds,
        uint256[] memory values
    ) internal virtual {
        require(
            tokenIds.length == values.length,
            "ERC5727: unmatched size of tokenIds and values"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _charge(tokenIds[i], values[i]);
        }
    }

    function _consume(uint256 tokenId, uint256 value) internal virtual {
        require(
            _getTokenOrRevert(tokenId).value > value,
            "ERC5727: not enough balance"
        );
        _getTokenOrRevert(tokenId).value -= value;
        emit Consumed(tokenId, value);
    }

    function _consumeBatch(
        uint256[] memory tokenIds,
        uint256[] memory values
    ) internal virtual {
        require(
            tokenIds.length == values.length,
            "ERC5727: unmatched size of tokenIds and values"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _consume(tokenIds[i], values[i]);
        }
    }

    function _revoke(uint256 tokenId) internal virtual {
        require(
            _getTokenOrRevert(tokenId).valid,
            "ERC5727: Token is already invalid"
        );
        _beforeTokenRevoke(tokenId);
        _tokens[tokenId].valid = false;
        _afterTokenRevoke(tokenId);
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

        _beforeTokenDestroy(tokenId);
        delete _tokens[tokenId];
        _afterTokenDestroy(tokenId);

        emit Consumed(tokenId, value);
        emit Destroyed(soul, tokenId);
        emit SlotChanged(tokenId, slot, 0);
    }

    function _isCreator() internal view virtual returns (bool) {
        return _msgSender() == owner();
    }

    function _beforeView(uint256 tokenId) internal view virtual {}

    function _beforeTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual {}

    function _afterTokenMint(
        address issuer,
        address soul,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal virtual {}

    function _beforeTokenRevoke(uint256 tokenId) internal virtual {}

    function _afterTokenRevoke(uint256 tokenId) internal virtual {}

    function _beforeTokenDestroy(uint256 tokenId) internal virtual {}

    function _afterTokenDestroy(uint256 tokenId) internal virtual {}

    function soulOf(
        uint256 tokenId
    ) public view virtual override returns (address) {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).soul;
    }

    function valueOf(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).value;
    }

    function slotOf(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).slot;
    }

    function issuerOf(
        uint256 tokenId
    ) public view virtual override returns (address) {
        return _getTokenOrRevert(tokenId).issuer;
    }

    function isValid(
        uint256 tokenId
    ) public view virtual override returns (bool) {
        _beforeView(tokenId);
        return _getTokenOrRevert(tokenId).valid;
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
    ) public view virtual override returns (string memory) {
        _getTokenOrRevert(tokenId);
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

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
}
