// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./ERC5342.sol";
import "./IERC5342Pull.sol";
import "./ERC5342Enumerable.sol";

abstract contract ERC5342Pull is ERC5342Enumerable, IERC5342Pull {
    using ECDSA for bytes32;

    function pull(address soul, bytes memory signature)
        public
        virtual
        override
    {
        address recipient = msg.sender;
        bytes32 messageHash = keccak256(abi.encodePacked(soul, recipient));
        bytes32 signedHash = messageHash.toEthSignedMessageHash();
        require(signedHash.recover(signature) == soul, "Invalid signature");
        uint256[] memory tokenIds = _tokensOfSoul(soul);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            Token storage token = _getTokenOrRevert(tokenIds[i]);
            address issuer = token.issuer;
            uint256 value = token.value;
            uint256 slot = token.slot;
            bool valid = token.valid;
            _destroy(tokenIds[i]);
            _mintUnsafe(issuer, soul, tokenIds[i], value, slot, valid);
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC5342Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5342Pull).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
