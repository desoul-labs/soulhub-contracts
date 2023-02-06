//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

error Unauthorized(address from);

error MethodNotAllowed(address from);

error NotFound(uint256 id);

error Conflict(uint256 id);

error Soulbound();

error BadReceiver(address to);

error Forbidden();

error InsufficientDelay();

error Challenge(address from);

error RecoveryPending(address from, address to);

error IndexOutOfBounds(uint256 index, uint256 length);

error NullValue();

error NotSupported();

error Mismatch(uint256 idA, uint256 idB);

error InsufficientBalance(uint256 balance, uint256 amount);

error PastDate();

error Expired(uint256 id);

error NoExpiration(uint256 id);

error NotRenewable(uint256 id);

error AlreadyRegistered(address registry);

error NotRegistered(address registry);

error InvalidRegistry(address registry);

error NotClaimable();

error AlreadyClaimed();
