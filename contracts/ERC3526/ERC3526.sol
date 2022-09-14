//SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IERC3526.sol";
import "./IERC3526Metadata.sol";
import "./IERC3526Enumerable.sol";

/**
 * @title ERC-3526
 */

abstract contract ERC3526 is
    IERC3526,
    IERC3526Metadata,
    IERC3526Enumerable,
    ERC165,
    Context
{
    using Address for address;
    using Strings for uint256;

    // Token data
    struct Token {
        address issuer;
        address owner;
        bool valid;
        uint256 value;
        uint256 slot;
    }

    // Mapping from tokenId to token
    mapping(uint256 => Token) private _tokens;

    // Mapping from owner to token ids
    mapping(address => uint256[]) private _indexedTokenIds;

    // Mapping from token id to index
    mapping(address => mapping(uint256 => uint256)) private _tokenIdIndex;

    // Mapping from owner to number of valid tokens
    mapping(address => uint256) private _numberOfValidTokens;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Total number of tokens emitted
    uint256 private _emittedCount;

    // Total number of token holders
    uint256 private _holdersCount;

    // Contract creator
    address private _creator;

    // Decimal position of values
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _creator = _msgSender();
        _decimals = decimals_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC3526).interfaceId ||
            interfaceId == type(IERC3526Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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

    /**
     * @notice get the decimal position.
     */
    function valueDecimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokens[tokenId].owner != address(0);
    }

    /**
     * @notice get the owner of a token and revert if it does not exist.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(_exists(tokenId), "ERC3526: token does not exist");
        return _tokens[tokenId].owner;
    }

    /**
     * @notice get the value of a token and revert if it does not exist.
     */
    function balanceOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(_exists(tokenId), "ERC3526: token does not exist");
        return _tokens[tokenId].value;
    }

    /**
     * @notice get the slot of a token and revert if it does not exist.
     */
    function slotOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(_exists(tokenId), "ERC3526: token does not exist");
        return _tokens[tokenId].slot;
    }

    /**
     * @notice get the slotURI of a slot.
     */
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

    /**
     * @notice Mint a new token
     * @param owner Address for whom to assign the token
     * @param value The value of the token
     * @param slot The slot of the token
     * @return tokenId Identifier of the minted token
     */
    function _mint(
        address owner,
        uint256 value,
        uint256 slot
    ) internal virtual returns (uint256 tokenId) {
        tokenId = _emittedCount;
        _mintUnsafe(owner, tokenId, value, slot, true);
        emit Minted(owner, tokenId, value);
        _emittedCount += 1;
    }

    /**
     * @notice Mint a given tokenId
     * @param owner Address for whom to assign the token
     * @param tokenId Token identifier to assign to the owner
     * @param value The value of the token
     * @param slot The slot of the token
     * @param valid Boolean to assert of the validity of the token
     */
    function _mintUnsafe(
        address owner,
        uint256 tokenId,
        uint256 value,
        uint256 slot,
        bool valid
    ) internal {
        require(
            _tokens[tokenId].owner == address(0),
            "ERC3526: Cannot mint an assigned token"
        );
        if (_indexedTokenIds[owner].length == 0) {
            _holdersCount += 1;
        }
        _tokens[tokenId] = Token(_msgSender(), owner, valid, value, slot);
        _tokenIdIndex[owner][tokenId] = _indexedTokenIds[owner].length;
        _indexedTokenIds[owner].push(tokenId);
        if (valid) {
            _numberOfValidTokens[owner] += 1;
        }
        emit SlotChanged(tokenId, 0, slot);
    }

    /**
     * @notice Burn a token
     * @param tokenId The ID of the token to burn
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        uint256 slot = slotOf(tokenId);
        uint256 value = balanceOf(tokenId);

        if (_tokens[tokenId].valid) {
            assert(_numberOfValidTokens[owner] > 0);
            _numberOfValidTokens[owner] -= 1;
        }
        delete _tokens[tokenId];
        _removeFromUnorderedArray(
            _indexedTokenIds[owner],
            _tokenIdIndex[owner][tokenId]
        );
        if (_indexedTokenIds[owner].length == 0) {
            assert(_holdersCount > 0);
            _holdersCount -= 1;
        }
        delete _tokenIdIndex[owner][tokenId];

        emit Burned(owner, tokenId, value);
        emit SlotChanged(tokenId, slot, 0);
    }

    /**
     * @notice Count the number of tokens assigned to an owner
     * @param owner Address for whom to query the balance
     * @return Number of tokens owned by `owner`
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _indexedTokenIds[owner].length;
    }

    /**
     * @notice Check if a token hasn't been revoked
     * @param tokenId Identifier of the token
     * @return True if the token is valid, false otherwise
     */
    function isValid(uint256 tokenId)
        public
        view
        virtual
        override
        returns (bool)
    {
        require(_exists(tokenId), "ERC3526: token does not exist");
        return _tokens[tokenId].valid;
    }

    /**
     * @notice Check if an address owns a valid token in the contract
     * @param owner Address for whom to check the ownership
     * @return True if `owner` has a valid token, false otherwise
     */
    function hasValid(address owner)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _numberOfValidTokens[owner] > 0;
    }

    /**
     * @return Descriptive name of the tokens in this contract
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @return An abbreviated name of the tokens in this contract
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice URI to query to get the token's metadata
     * @param tokenId Identifier of the token
     * @return URI for the token
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _exists(tokenId);
        bytes memory baseURI = bytes(_baseURI());
        if (baseURI.length > 0) {
            return
                string(
                    abi.encodePacked(baseURI, Strings.toHexString(tokenId, 32))
                );
        }
        return "";
    }

    /**
     * @return emittedCount Number of tokens emitted
     */
    function emittedCount() public view override returns (uint256) {
        return _emittedCount;
    }

    /**
     * @return holdersCount Number of token holders
     */
    function holdersCount() public view override returns (uint256) {
        return _holdersCount;
    }

    /**
     *  @notice Get the tokenId of a token using its position in the owner's list
     *  @param owner Address for whom to get the token
     *  @param index Index of the token
     *  @return tokenId of the token
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256[] storage ids = _indexedTokenIds[owner];
        require(index < ids.length, "ERC3526: Token does not exist");
        return ids[index];
    }

    /**
     *  @notice Get a tokenId by it's index, where 0 <= index < total()
     *  @param index Index of the token
     *  @return tokenId of the token
     */
    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return index;
    }

    /**
     *  @notice Prefix for all calls to tokenURI
     *  @return Common base URI for all token
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     *  @notice Mark the token as revoked
     *  @param tokenId Identifier of the token
     */
    function _revoke(uint256 tokenId) internal virtual {
        _exists(tokenId);
        require(_tokens[tokenId].valid, "ERC3526: Token is already invalid");
        _tokens[tokenId].valid = false;
        assert(_numberOfValidTokens[_tokens[tokenId].owner] > 0);
        _numberOfValidTokens[_tokens[tokenId].owner] -= 1;
        emit Revoked(_tokens[tokenId].owner, tokenId);
    }

    /**
     *  @return True if the caller is the contract's creator, false otherwise
     */
    function _isCreator() internal view virtual returns (bool) {
        return _msgSender() == _creator;
    }

    /**
     *  @notice Removes an entry in an array by its index
     *  @param array Array for which to remove the entry
     *  @param index Index of the entry to remove
     */
    function _removeFromUnorderedArray(uint256[] storage array, uint256 index)
        internal
    {
        require(index < array.length, "ERC3526: Index overflow");
        if (index != array.length - 1) {
            array[index] = array[array.length - 1];
        }
        array.pop();
    }

    /**
     *  @notice Retrieve a token or revert if it does not exist
     *  @param tokenId Identifier of the token
     *  @return The Token struct
     */
    function _getTokenOrRevert(uint256 tokenId)
        internal
        view
        virtual
        returns (Token storage)
    {
        Token storage token = _tokens[tokenId];
        require(token.owner != address(0), "ERC3526: Token does not exist");
        return token;
    }
}
