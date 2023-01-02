//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

error Unauthorized(address from);

error MethodNotAllowed(address from);

error NotFound(uint256 tokenId);

error Conflict(uint256 tokenId);

error TokenLocked(uint256 tokenId);

error BadReceiver(address to);

error Forbidden();

error IndexOutOfBounds(uint256 index, uint256 length);

error NullValue();

error NotSupported();

error Mismatch(uint256 idA, uint256 idB);

error InsufficientBalance(uint256 balance, uint256 amount);

error PastDate();

error Expired(uint256 tokenId);

error NotRenewable(uint256 tokenId);

error AlreadyRegistered(address registry);

error NotRegistered(address registry);

error InvalidRegistry(address registry);
