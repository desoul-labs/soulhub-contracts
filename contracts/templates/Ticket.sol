// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../ERC4671/IERC4671.sol";

contract Ticket is
    Context,
    AccessControlEnumerable,
    Ownable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable,
    IERC4671
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURIBefore;
    string private _baseTokenURIAfter;

    address private _trigger;

    mapping (uint256 => bool) private _disableTransfer;

    event Mint(address indexed to, uint256 indexed tokenId);

    event Used(address indexed user, uint256 indexed tokenId, address indexed trigger);

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURIBefore,
        string memory baseTokenURIAfter,
        address trigger
    ) ERC721(name, symbol) {
        _baseTokenURIBefore = baseTokenURIBefore;
        _baseTokenURIAfter = baseTokenURIAfter;
        _trigger = trigger;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function isValid(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    function hasValid(address owner) external view returns (bool) {
        return balanceOf(owner) != 0;
    }

    function isTransferable(uint256 tokenId) public view returns (bool) {
        return !_disableTransfer[tokenId];
    }

    function _baseURIBefore() internal view virtual returns (string memory) {
        return _baseTokenURIBefore;
    }

    function _baseURIAfter() internal view virtual returns (string memory) {
        return _baseTokenURIAfter;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = isTransferable(tokenId) ? _baseURIBefore() : _baseURIAfter();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function mint(address to) public payable virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        emit Mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
        payable(owner()).transfer(msg.value);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        require(isTransferable(tokenId), "Transfer is not allowed");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId) || interfaceId == type(IERC4671).interfaceId;
    }

    function use(address user, uint256 tokenId) external virtual {
        require(_msgSender() == _trigger, "Only the trigger contract can trigger this event");
        require(user == tx.origin && user == ownerOf(tokenId), "Ticket not owned by caller");
        require(isTransferable(tokenId), "Ticket has already been used");
        _disableTransfer[tokenId] = true;

        emit Used(user, tokenId, _msgSender());
    }

    function balanceOf(address owner) public view override(ERC721, IERC721, IERC4671) returns (uint256) {
        return ERC721.balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view override(ERC721, IERC721, IERC4671) returns (address) {
        return ERC721.ownerOf(tokenId);
    }
}
