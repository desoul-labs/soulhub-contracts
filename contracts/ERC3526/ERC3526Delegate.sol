// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./ERC3526.sol";
import "./IERC3526Delegate.sol";

abstract contract ERC3526Delegate is ERC3526, IERC3526Delegate {
    // Delegate Request
    struct DelegateRequest {
        address owner;
        uint256 value;
        uint256 slot;
    }

    // Number of delegate requests
    uint256 private _delegateRequestCount;

    // Mapping from delegate request ID to delegate requests
    mapping(uint256 => DelegateRequest) private _delegateRequests;

    // Mapping from operator to list of delegateRequestIds
    mapping(address => mapping(uint256 => bool)) private _allowed;

    /**
     *  @notice Grant one-time minting right to `operator` for `delegateRequestId`
     *  An allowed operator can call the function to transfer rights.
     *  @param operator Address allowed to mint a token
     *  @param delegateRequestId Address for whom `operator` is allowed to mint a token
     */
    function delegate(address operator, uint256 delegateRequestId)
        public
        virtual
        override
    {
        _delegateAsDelegateOrCreator(operator, delegateRequestId, _isCreator());
    }

    /**
     *  @notice Grant one-time minting right to a list of `operators` for a corresponding list of `delegateRequestIds`
     *  An allowed operator can call the function to transfer rights.
     *  @param operators Addresses allowed to mint a token
     *  @param delegateRequestIds Addresses for whom `operators` are allowed to mint a token
     */
    function delegateBatch(
        address[] memory operators,
        uint256[] memory delegateRequestIds
    ) public virtual override {
        require(
            operators.length == delegateRequestIds.length,
            "operators and delegateRequestIds must have the same length"
        );
        bool isCreator = _isCreator();
        for (uint256 i = 0; i < operators.length; i++) {
            _delegateAsDelegateOrCreator(
                operators[i],
                delegateRequestIds[i],
                isCreator
            );
        }
    }

    /**
     *  @notice Mint a token. Caller must have the right to mint for the delegateRequestId.
     *  @param delegateRequestId Address for whom the token is minted
     */
    function mint(uint256 delegateRequestId) public virtual override {
        _mintAsDelegateOrCreator(delegateRequestId, _isCreator());
    }

    /**
     *  @notice Mint tokens to multiple addresses. Caller must have the right to mint for all delegateRequestIds.
     *  @param delegateRequestIds Addresses for whom the tokens are minted
     */
    function mintBatch(uint256[] memory delegateRequestIds)
        public
        virtual
        override
    {
        bool isCreator = _isCreator();
        for (uint256 i = 0; i < delegateRequestIds.length; i++) {
            _mintAsDelegateOrCreator(delegateRequestIds[i], isCreator);
        }
    }

    /**
     *  @notice Get the issuer of a token
     *  @param tokenId Identifier of the token
     *  @return Address who minted `tokenId`
     */
    function issuerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        return _getTokenOrRevert(tokenId).issuer;
    }

    /**
     *  @notice Check if an operator is a delegate for a given address
     *  @param operator Address of the operator
     *  @param delegateRequestId Address of the token's delegateRequestId
     *  @return True if the `operator` is a delegate for `delegateRequestId`, false otherwise
     */
    function isDelegate(address operator, uint256 delegateRequestId)
        public
        view
        virtual
        returns (bool)
    {
        return _allowed[operator][delegateRequestId];
    }

    /**
     *  @notice Check if you are a delegate for a given address
     *  @param delegateRequestId Address of the token's delegateRequestId
     *  @return True if the caller is a delegate for `delegateRequestId`, false otherwise
     */
    function isDelegateOf(uint256 delegateRequestId)
        public
        view
        virtual
        returns (bool)
    {
        return isDelegate(_msgSender(), delegateRequestId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC3526)
        returns (bool)
    {
        return
            interfaceId == type(IERC3526Delegate).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _delegateAsDelegateOrCreator(
        address operator,
        uint256 delegateRequestId,
        bool isCreator
    ) private {
        require(
            isCreator || _allowed[_msgSender()][delegateRequestId],
            "Only contract creator or allowed operator can delegate"
        );
        if (!isCreator) {
            _allowed[_msgSender()][delegateRequestId] = false;
        }
        _allowed[operator][delegateRequestId] = true;
    }

    function _mintAsDelegateOrCreator(uint256 delegateRequestId, bool isCreator)
        private
    {
        require(
            isCreator || _allowed[_msgSender()][delegateRequestId],
            "Only contract creator or allowed operator can mint"
        );
        if (!isCreator) {
            _allowed[_msgSender()][delegateRequestId] = false;
        }
        _mint(
            _delegateRequests[delegateRequestId].owner,
            _delegateRequests[delegateRequestId].value,
            _delegateRequests[delegateRequestId].slot
        );
    }

    function createDelegateRequest(
        address owner,
        uint256 value,
        uint256 slot
    ) external virtual override {
        require(_isCreator(), "You are not the creator");
        _delegateRequests[_delegateRequestCount].owner = owner;
        _delegateRequests[_delegateRequestCount].value = value;
        _delegateRequests[_delegateRequestCount].slot = slot;
        _delegateRequestCount++;
    }

    function removeDelegateRequest(uint256 delegateRequestId)
        external
        virtual
        override
    {
        require(_isCreator(), "You are not the creator");
        delete _delegateRequests[delegateRequestId];
    }
}
