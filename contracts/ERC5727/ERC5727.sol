//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "../ERC3525/ERC3525.sol";
import "./interfaces/IERC5727.sol";
import "./interfaces/IERC5727Metadata.sol";
import "./interfaces/IERC5727Enumerable.sol";

contract ERC5727 is AccessControlEnumerable, ERC3525, IERC5727 {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => bool) internal _unlocked;

    mapping(uint256 => address) internal _issuers;
    mapping(uint256 => address) internal _verifiers;
    mapping(uint256 => address) internal _slotVerifiers;
    mapping(uint256 => BurnAuth) internal _burnAuths;

    bytes32 public constant MINTER_ROLE = bytes32(uint256(0x01));
    bytes32 public constant BURNER_ROLE = bytes32(uint256(0x02));

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender()))
            revert Unauthorized(_msgSender());
        _;
    }

    modifier onlyMinter(uint256 tokenId) {
        if (_checkMintAuth(_msgSender(), tokenId))
            revert Unauthorized(_msgSender());
        _;
    }

    modifier onlyBurner(uint256 tokenId) {
        if (_checkBurnAuth(_msgSender(), tokenId))
            revert Unauthorized(_msgSender());
        _;
    }

    modifier onlyManager(uint256 tokenId) {
        if (
            _msgSender() != _issuers[tokenId] &&
            !hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        ) revert Unauthorized(_msgSender());
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address admin
    ) ERC3525(name_, symbol_, 18) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function locked(
        uint256 tokenId
    ) public view virtual override returns (bool) {
        _requireMinted(tokenId);

        return !_unlocked[tokenId];
    }

    function setVerifier(
        uint256 tokenId,
        address verifier
    ) public virtual override onlyManager(tokenId) {
        _requireMinted(tokenId);
        if (verifier == address(0)) revert NullValue();

        _verifiers[tokenId] = verifier;

        emit UpdateVerifier(tokenId, verifier);
    }

    function setSlotVerifier(
        uint256 slot,
        address verifier
    ) public virtual override onlyAdmin {
        if (verifier == address(0)) revert NullValue();

        _slotVerifiers[slot] = verifier;

        emit UpdateSlotVerifier(slot, verifier);
    }

    function verifierOf(
        uint256 tokenId
    ) external view virtual override returns (address) {
        address verifier = _verifiers[tokenId];
        if (verifier == address(0)) revert NotFound(tokenId);

        return verifier;
    }

    function issuerOf(
        uint256 tokenId
    ) external view virtual override returns (address) {
        address issuer = _issuers[tokenId];
        if (issuer == address(0)) revert NotFound(tokenId);

        return issuer;
    }

    function issue(
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth auth,
        bytes calldata data
    ) public payable virtual override onlyMinter(tokenId) {
        if (tokenId == 0 || slot == 0 || to == address(0)) revert NullValue();

        _issue(_msgSender(), to, tokenId, amount, slot, auth);

        data;
    }

    function _issue(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 slot,
        BurnAuth auth
    ) internal virtual {
        _mintValue(to, tokenId, slot, amount);

        _issuers[tokenId] = from;
        _burnAuths[tokenId] = auth;

        if (auth == BurnAuth.IssuerOnly) {
            _grantRole(BURNER_ROLE ^ bytes32(tokenId), from);
            _approve(from, tokenId);
            _approveValue(tokenId, from, amount);
        }
        if (auth == BurnAuth.OwnerOnly) {
            _grantRole(BURNER_ROLE ^ bytes32(tokenId), to);
        }
        if (auth == BurnAuth.Both) {
            _grantRole(BURNER_ROLE ^ bytes32(tokenId), from);
            _grantRole(BURNER_ROLE ^ bytes32(tokenId), to);
            _approve(from, tokenId);
            _approveValue(tokenId, from, amount);
        }

        emit Issued(from, to, tokenId, auth);

        _verifiers[tokenId] = from;
    }

    function revoke(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) public payable virtual override onlyBurner(tokenId) {
        if (tokenId == 0) revert NullValue();
        _requireMinted(tokenId);

        _revoke(_msgSender(), tokenId, amount);

        data;
    }

    function burnAuth(
        uint256 tokenId
    ) external view virtual override returns (BurnAuth) {
        _requireMinted(tokenId);

        return _burnAuths[tokenId];
    }

    function _checkBurnAuth(
        address from,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return hasRole(BURNER_ROLE ^ bytes32(tokenId), from);
    }

    function _checkMintAuth(
        address from,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return
            hasRole(DEFAULT_ADMIN_ROLE, from) ||
            hasRole(MINTER_ROLE ^ bytes32(tokenId), from);
    }

    function _burn(uint256 tokenId) internal virtual override {
        ERC3525._burn(tokenId);

        delete _issuers[tokenId];
        delete _verifiers[tokenId];
        delete _burnAuths[tokenId];
    }

    function _revoke(
        address from,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        if (amount == _values[tokenId]) {
            _burn(tokenId);
        }
        _burnValue(tokenId, amount);

        emit Revoked(from, tokenId);
    }

    function verify(
        uint256 tokenId,
        bytes calldata data
    ) public virtual override returns (bool result) {
        if (tokenId == 0) revert NullValue();
        _requireMinted(tokenId);

        result = _verify(_msgSender(), tokenId);

        data;
    }

    function _verify(
        address by,
        uint256 tokenId
    ) internal virtual returns (bool) {
        bool result = _verifiers[tokenId] == _issuers[tokenId];

        emit Verified(by, tokenId, result);

        return result;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (locked(firstTokenId)) revert TokenLocked(firstTokenId);

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _beforeValueTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 slot,
        uint256 value
    ) internal virtual override {
        if (locked(fromTokenId) || locked(toTokenId))
            revert TokenLocked(fromTokenId);

        super._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165, ERC3525, AccessControlEnumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727).interfaceId ||
            interfaceId == type(IERC5727Metadata).interfaceId ||
            interfaceId == type(IERC5727Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
