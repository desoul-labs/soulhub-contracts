//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol";

import "../EIP712/EIP712Upgradeable.sol";
import "./interfaces/IERC5727MetadataUpgradeable.sol";
import "./interfaces/IERC5727EnumerableUpgradeable.sol";
import "../ERC173/ERC173Upgradeable.sol";
import "../diamond/libraries/LibDiamond.sol";
import "./ERC5727Storage.sol";
import "../ERC3525/ERC3525Core.sol";
import "../ERC5484/interfaces/IERC5484Upgradeable.sol";

contract ERC5727Core is EIP712Upgradeable, ERC3525Core {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SignatureCheckerUpgradeable for address;

    event Issued(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        IERC5484Upgradeable.BurnAuth burnAuth
    );
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);
    event Revoked(address indexed from, uint256 indexed tokenId);
    event Verified(address indexed by, uint256 indexed tokenId, bool result);

    bytes32 private constant _TOKEN_TYPEHASH =
        keccak256(
            "Token(uint256 tokenId,address owner,uint256 value,uint256 slot,address issuer,address verifier,BurnAuth burnAuth)"
        );

    modifier onlyAdmin() {
        if (owner() != _msgSender()) revert Unauthorized(_msgSender());
        _;
    }

    modifier onlyMinter(uint256 slot) {
        if (!_checkMintAuth(_msgSender(), slot))
            revert Unauthorized(_msgSender());
        _;
    }

    modifier onlyBurner(uint256 tokenId) {
        if (!_checkBurnAuth(_msgSender(), tokenId))
            revert Unauthorized(_msgSender());
        _;
    }

    modifier onlyIssuer(uint256 tokenId) {
        if (_msgSender() != LibERC5727Storage.s()._issuers[tokenId])
            revert Unauthorized(_msgSender());
        _;
    }

    function owner() internal view returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }

    function verifierOf(
        uint256 tokenId
    ) internal view virtual returns (address) {
        address verifier = LibERC5727Storage.s()._verifiers[tokenId];
        if (verifier == address(0)) revert NotFound(tokenId);

        return verifier;
    }

    function issuerOf(uint256 tokenId) internal view virtual returns (address) {
        address issuer = LibERC5727Storage.s()._issuers[tokenId];
        if (issuer == address(0)) revert NotFound(tokenId);

        return issuer;
    }

    function issue(
        address to,
        uint256 tokenId,
        uint256 slot,
        IERC5484Upgradeable.BurnAuth auth,
        address verifier,
        bytes calldata data
    ) internal virtual onlyMinter(slot) {
        if (tokenId == 0 || slot == 0 || to == address(0)) revert NullValue();

        _issue(_msgSender(), to, tokenId, slot, auth, verifier);

        data;
    }

    function issue(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) internal virtual onlyIssuer(tokenId) {
        _requireMinted(tokenId);

        _issue(_msgSender(), tokenId, amount);

        data;
    }

    function _issue(
        address from,
        address to,
        uint256 tokenId,
        uint256 slot,
        IERC5484Upgradeable.BurnAuth auth,
        address verifier
    ) internal virtual {
        _mint(to, tokenId, slot);

        LibERC5727Storage.s()._issuers[tokenId] = from;
        LibERC5727Storage.s()._burnAuths[tokenId] = auth;
        LibERC5727Storage.s()._verifiers[tokenId] = verifier;

        if (
            auth == IERC5484Upgradeable.BurnAuth.IssuerOnly ||
            auth == IERC5484Upgradeable.BurnAuth.Both
        ) {
            LibERC5727Storage.s()._burnerRole[tokenId][from] = true;
            _approve(from, tokenId);
        }
        if (
            auth == IERC5484Upgradeable.BurnAuth.OwnerOnly ||
            auth == IERC5484Upgradeable.BurnAuth.Both
        ) {
            LibERC5727Storage.s()._burnerRole[tokenId][to] = true;
        }

        emit Issued(from, to, tokenId, auth);
        emit Locked(tokenId);

        _beforeValueTransfer(address(0), to, 0, tokenId, slot, 0);
        _afterValueTransfer(address(0), to, 0, tokenId, slot, 0);
    }

    function _issue(
        address from,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        _mint(tokenId, amount);

        IERC5484Upgradeable.BurnAuth auth = LibERC5727Storage.s()._burnAuths[
            tokenId
        ];

        if (
            auth == IERC5484Upgradeable.BurnAuth.IssuerOnly ||
            auth == IERC5484Upgradeable.BurnAuth.Both
        ) {
            _approve(tokenId, from, amount);
        }
    }

    function revoke(
        uint256 tokenId,
        bytes calldata data
    ) internal virtual onlyBurner(tokenId) {
        _requireMinted(tokenId);

        _revoke(_msgSender(), tokenId, balanceOf(tokenId));

        data;
    }

    function revoke(
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) internal virtual onlyBurner(tokenId) {
        _requireMinted(tokenId);

        _revoke(_msgSender(), tokenId, amount);

        data;
    }

    function locked(uint256 tokenId) internal view virtual returns (bool) {
        _requireMinted(tokenId);

        return !LibERC5727Storage.s()._unlocked[tokenId];
    }

    function burnAuth(
        uint256 tokenId
    ) internal view virtual returns (IERC5484Upgradeable.BurnAuth) {
        _requireMinted(tokenId);

        return LibERC5727Storage.s()._burnAuths[tokenId];
    }

    function _checkBurnAuth(
        address from,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return LibERC5727Storage.s()._burnerRole[tokenId][from];
    }

    function _checkMintAuth(
        address from,
        uint256 slot
    ) internal view virtual returns (bool) {
        return
            (owner() == from) || LibERC5727Storage.s()._minterRole[slot][from];
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        delete LibERC5727Storage.s()._issuers[tokenId];
        delete LibERC5727Storage.s()._verifiers[tokenId];
        delete LibERC5727Storage.s()._burnAuths[tokenId];
    }

    function _revoke(address from, uint256 tokenId) internal virtual {
        LibERC5727Storage.s()._revoked[tokenId] = true;
        emit Revoked(from, tokenId);
    }

    function _revoke(
        address from,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        _burn(tokenId, amount);

        from;
    }

    function verify(
        uint256 tokenId,
        bytes calldata data
    ) internal virtual returns (bool result) {
        _requireMinted(tokenId);

        // TODO: use actual verifier
        result = _verify(_msgSender(), tokenId, data);

        data;
    }

    function _verify(
        address by,
        uint256 tokenId,
        bytes memory data
    ) internal virtual returns (bool result) {
        bytes memory signature = abi.decode(data, (bytes));
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    _TOKEN_TYPEHASH,
                    tokenId,
                    ownerOf(tokenId),
                    balanceOf(tokenId),
                    slotOf(tokenId),
                    issuerOf(tokenId),
                    verifierOf(tokenId),
                    burnAuth(tokenId)
                )
            )
        );

        address issuer = LibERC5727Storage.s()._issuers[tokenId];
        result = issuer.isValidSignatureNow(digest, signature);

        emit Verified(by, tokenId, result);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (
            from != address(0) &&
            to != address(0) &&
            !LibERC5727Storage.s()._unlocked[firstTokenId]
        ) revert Soulbound();
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
        if (from != address(0) && to != address(0)) revert Soulbound();

        super._beforeValueTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            slot,
            value
        );
    }
}
