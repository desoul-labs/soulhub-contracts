// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC5727.sol";
import "./interfaces/IERC5727Delegate.sol";
import "./ERC5727Enumerable.sol";

abstract contract ERC5727Delegate is ERC5727Enumerable, IERC5727Delegate {
    struct DelegateRequest {
        address soul;
        uint256 value;
        uint256 slot;
    }

    uint256 private _delegateRequestCount;

    mapping(uint256 => DelegateRequest) private _delegateRequests;

    mapping(address => mapping(uint256 => bool)) private _mintAllowed;

    mapping(address => mapping(uint256 => bool)) private _revokeAllowed;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC5727Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC5727Delegate).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _mintDelegateAsDelegateOrCreator(
        address operator,
        uint256 delegateRequestId,
        bool isCreator
    ) private {
        require(
            isCreator || _mintAllowed[_msgSender()][delegateRequestId],
            "ERC5727Delegate: Only contract creator or allowed operator can delegate"
        );
        if (!isCreator) {
            _mintAllowed[_msgSender()][delegateRequestId] = false;
        }
        _mintAllowed[operator][delegateRequestId] = true;
    }

    function _revokeDelegateAsDelegateOrCreator(
        address operator,
        uint256 tokenId,
        bool isCreator
    ) private {
        require(
            isCreator || _revokeAllowed[_msgSender()][tokenId],
            "ERC5727Delegate: Only contract creator or allowed operator can delegate"
        );
        if (!isCreator) {
            _revokeAllowed[_msgSender()][tokenId] = false;
        }
        _revokeAllowed[operator][tokenId] = true;
    }

    function _mintAsDelegateOrCreator(uint256 delegateRequestId, bool isCreator)
        private
    {
        require(
            isCreator || _mintAllowed[_msgSender()][delegateRequestId],
            "ERC5727Delegate: Only contract creator or allowed operator can mint"
        );
        if (!isCreator) {
            _mintAllowed[_msgSender()][delegateRequestId] = false;
        }
        _mint(
            _delegateRequests[delegateRequestId].soul,
            _delegateRequests[delegateRequestId].value,
            _delegateRequests[delegateRequestId].slot
        );
    }

    function _revokeAsDelegateOrCreator(uint256 tokenId, bool isCreator)
        private
    {
        require(
            isCreator || _revokeAllowed[_msgSender()][tokenId],
            "ERC5727Delegate: Only contract creator or allowed operator can revoke"
        );
        if (!isCreator) {
            _revokeAllowed[_msgSender()][tokenId] = false;
        }
        _revoke(tokenId);
    }

    function mintDelegate(address operator, uint256 delegateRequestId)
        public
        virtual
        override
    {
        _mintDelegateAsDelegateOrCreator(
            operator,
            delegateRequestId,
            _isCreator()
        );
    }

    function mintDelegateBatch(
        address[] memory operators,
        uint256[] memory delegateRequestIds
    ) public virtual override {
        require(
            operators.length == delegateRequestIds.length,
            "ERC5727Delegate: operators and delegateRequestIds must have the same length"
        );
        bool isCreator = _isCreator();
        for (uint256 i = 0; i < operators.length; i++) {
            _mintDelegateAsDelegateOrCreator(
                operators[i],
                delegateRequestIds[i],
                isCreator
            );
        }
    }

    function revokeDelegate(address operator, uint256 tokenId)
        public
        virtual
        override
    {
        _revokeDelegateAsDelegateOrCreator(operator, tokenId, _isCreator());
    }

    function revokeDelegateBatch(
        address[] memory operators,
        uint256[] memory tokenIds
    ) public virtual override {
        require(
            operators.length == tokenIds.length,
            "ERC5727Delegate: operators and tokenIds must have the same length"
        );
        bool isCreator = _isCreator();
        for (uint256 i = 0; i < operators.length; i++) {
            _revokeDelegateAsDelegateOrCreator(
                operators[i],
                tokenIds[i],
                isCreator
            );
        }
    }

    function delegateMint(uint256 delegateRequestId) public virtual override {
        _mintAsDelegateOrCreator(delegateRequestId, _isCreator());
    }

    function delegateMintBatch(uint256[] memory delegateRequestIds)
        public
        virtual
        override
    {
        bool isCreator = _isCreator();
        for (uint256 i = 0; i < delegateRequestIds.length; i++) {
            _mintAsDelegateOrCreator(delegateRequestIds[i], isCreator);
        }
    }

    function delegateRevoke(uint256 tokenId) public virtual override {
        _revokeAsDelegateOrCreator(tokenId, _isCreator());
    }

    function delegateRevokeBatch(uint256[] memory tokenIds)
        public
        virtual
        override
    {
        bool isCreator = _isCreator();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _revokeAsDelegateOrCreator(tokenIds[i], isCreator);
        }
    }

    function createDelegateRequest(
        address soul,
        uint256 value,
        uint256 slot
    ) external virtual override returns (uint256 delegateRequestId) {
        require(_isCreator(), "ERC5727Delegate: You are not the creator");
        require(
            value != 0,
            "ERC5727Delegate: Value of Delegate Request cannot be zero"
        );
        delegateRequestId = _delegateRequestCount;
        _delegateRequests[_delegateRequestCount].soul = soul;
        _delegateRequests[_delegateRequestCount].value = value;
        _delegateRequests[_delegateRequestCount].slot = slot;
        _delegateRequestCount++;
    }

    function removeDelegateRequest(uint256 delegateRequestId)
        external
        virtual
        override
    {
        require(_isCreator(), "ERC5727Delegate: You are not the creator");
        delete _delegateRequests[delegateRequestId];
    }
}
