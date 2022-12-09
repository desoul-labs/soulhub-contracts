# ERC5727Example

## Methods

### DEFAULT_ADMIN_ROLE

```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32)
```

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | bytes32 | undefined   |

### VOTER_ROLE

```solidity
function VOTER_ROLE() external view returns (bytes32)
```

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | bytes32 | undefined   |

### addVoter

```solidity
function addVoter(address newVoter) external nonpayable
```

Add a new voter `newVoter`.

_MUST revert if the caller is not an administrator. MUST revert if `newVoter` is already a voter._

#### Parameters

| Name     | Type    | Description          |
| -------- | ------- | -------------------- |
| newVoter | address | the new voter to add |

### approveMint

```solidity
function approveMint(address soul, uint256 approvalRequestId) external nonpayable
```

Approve to mint the token described by the `approvalRequestId` to `soul`.

_MUST revert if the caller is not a voter._

#### Parameters

| Name              | Type    | Description                                                             |
| ----------------- | ------- | ----------------------------------------------------------------------- |
| soul              | address | The soul which the token to mint to                                     |
| approvalRequestId | uint256 | The approval request describing the value and slot of the token to mint |

### approveRevoke

```solidity
function approveRevoke(uint256 tokenId) external nonpayable
```

Approve to revoke the `tokenId`.

_MUST revert if the `tokenId` does not exist._

#### Parameters

| Name    | Type    | Description         |
| ------- | ------- | ------------------- |
| tokenId | uint256 | The token to revert |

### balanceOf

```solidity
function balanceOf(address soul) external view returns (uint256)
```

Get the number of tokens owned by the `soul`.

_MUST revert if the `soul` does not have any token._

#### Parameters

| Name | Type    | Description                           |
| ---- | ------- | ------------------------------------- |
| soul | address | The soul whose balance is queried for |

#### Returns

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| \_0  | uint256 | The number of tokens of the `soul` |

### collect

```solidity
function collect(uint256 slotId) external payable
```

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| slotId | uint256 | undefined   |

### contractURI

```solidity
function contractURI() external view returns (string)
```

Get the URI of the contract.

#### Returns

| Name | Type   | Description             |
| ---- | ------ | ----------------------- |
| \_0  | string | The URI of the contract |

### createApprovalRequest

```solidity
function createApprovalRequest(uint256 value, uint256 slot) external nonpayable
```

Create an approval request describing the `value` and `slot` of a token.

_MUST revert when `value` is zero._

#### Parameters

| Name  | Type    | Description                                 |
| ----- | ------- | ------------------------------------------- |
| value | uint256 | The value of the approval request to create |
| slot  | uint256 | undefined                                   |

### createDelegateRequest

```solidity
function createDelegateRequest(address soul, uint256 value, uint256 slot) external nonpayable returns (uint256 delegateRequestId)
```

Create a delegate request describing the `soul`, `value` and `slot` of a token.

#### Parameters

| Name  | Type    | Description                        |
| ----- | ------- | ---------------------------------- |
| soul  | address | The soul of the delegate request.  |
| value | uint256 | The value of the delegate request. |
| slot  | uint256 | The slot of the delegate request.  |

#### Returns

| Name              | Type    | Description                    |
| ----------------- | ------- | ------------------------------ |
| delegateRequestId | uint256 | The id of the delegate request |

### createSlot

```solidity
function createSlot(uint256 maxSupply, uint256[] values, uint256[] expiryDates, uint256[] fees, bool[] shadowed) external nonpayable
```

#### Parameters

| Name        | Type      | Description |
| ----------- | --------- | ----------- |
| maxSupply   | uint256   | undefined   |
| values      | uint256[] | undefined   |
| expiryDates | uint256[] | undefined   |
| fees        | uint256[] | undefined   |
| shadowed    | bool[]    | undefined   |

### delegateMint

```solidity
function delegateMint(uint256 delegateRequestId) external nonpayable
```

Mint a token described by `delegateRequestId` delegate request as a delegate.

_MUST revert if the caller is not delegated._

#### Parameters

| Name              | Type    | Description                                                                     |
| ----------------- | ------- | ------------------------------------------------------------------------------- |
| delegateRequestId | uint256 | The delegate requests describing the soul, value and slot of the token to mint. |

### delegateMintBatch

```solidity
function delegateMintBatch(uint256[] delegateRequestIds) external nonpayable
```

Mint tokens described by `delegateRequestIds` delegate request as a delegate.

_MUST revert if the caller is not delegated._

#### Parameters

| Name               | Type      | Description                                                                      |
| ------------------ | --------- | -------------------------------------------------------------------------------- |
| delegateRequestIds | uint256[] | The delegate requests describing the soul, value and slot of the tokens to mint. |

### delegateRevoke

```solidity
function delegateRevoke(uint256 tokenId) external nonpayable
```

Revoke a token as a delegate.

_MUST revert if the caller is not delegated._

#### Parameters

| Name    | Type    | Description          |
| ------- | ------- | -------------------- |
| tokenId | uint256 | The token to revoke. |

### delegateRevokeBatch

```solidity
function delegateRevokeBatch(uint256[] tokenIds) external nonpayable
```

Revoke multiple tokens as a delegate.

_MUST revert if the caller is not delegated._

#### Parameters

| Name     | Type      | Description           |
| -------- | --------- | --------------------- |
| tokenIds | uint256[] | The tokens to revoke. |

### delegatedRequestsOf

```solidity
function delegatedRequestsOf(address operator) external view returns (uint256[])
```

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| operator | address | undefined   |

#### Returns

| Name | Type      | Description |
| ---- | --------- | ----------- |
| \_0  | uint256[] | undefined   |

### delegatedTokensOf

```solidity
function delegatedTokensOf(address operator) external view returns (uint256[])
```

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| operator | address | undefined   |

#### Returns

| Name | Type      | Description |
| ---- | --------- | ----------- |
| \_0  | uint256[] | undefined   |

### emittedCount

```solidity
function emittedCount() external view returns (uint256)
```

Get the total number of tokens emitted.

#### Returns

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| \_0  | uint256 | The total number of tokens emitted |

### expiryDate

```solidity
function expiryDate(uint256 tokenId) external view returns (uint256)
```

Get the expire date of a token.

_MUST revert if the `tokenId` token does not exist._

#### Parameters

| Name    | Type    | Description                                    |
| ------- | ------- | ---------------------------------------------- |
| tokenId | uint256 | The token for which the expiry date is queried |

#### Returns

| Name | Type    | Description                  |
| ---- | ------- | ---------------------------- |
| \_0  | uint256 | The expiry date of the token |

### getRoleAdmin

```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32)
```

_Returns the admin role that controls `role`. See {grantRole} and {revokeRole}. To change a role&#39;s admin, use {\_setRoleAdmin}._

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| role | bytes32 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | bytes32 | undefined   |

### getRoleMember

```solidity
function getRoleMember(bytes32 role, uint256 index) external view returns (address)
```

_Returns one of the accounts that have `role`. `index` must be a value between 0 and {getRoleMemberCount}, non-inclusive. Role bearers are not sorted in any particular way, and their ordering may change at any point. WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure you perform all queries on the same block. See the following https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post] for more information._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| role  | bytes32 | undefined   |
| index | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### getRoleMemberCount

```solidity
function getRoleMemberCount(bytes32 role) external view returns (uint256)
```

_Returns the number of accounts that have `role`. Can be used together with {getRoleMember} to enumerate all bearers of a role._

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| role | bytes32 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### grantRole

```solidity
function grantRole(bytes32 role, address account) external nonpayable
```

_Grants `role` to `account`. If `account` had not been already granted `role`, emits a {RoleGranted} event. Requirements: - the caller must have `role`&#39;s admin role. May emit a {RoleGranted} event._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| role    | bytes32 | undefined   |
| account | address | undefined   |

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```

_Returns `true` if `account` has been granted `role`._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| role    | bytes32 | undefined   |
| account | address | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### hasValid

```solidity
function hasValid(address soul) external view returns (bool)
```

Get if the `soul` owns any valid tokens.

#### Parameters

| Name | Type    | Description                                          |
| ---- | ------- | ---------------------------------------------------- |
| soul | address | The soul whose valid token infomation is queried for |

#### Returns

| Name | Type | Description                         |
| ---- | ---- | ----------------------------------- |
| \_0  | bool | if the `soul` owns any valid tokens |

### isExpired

```solidity
function isExpired(uint256 tokenId) external view returns (bool)
```

Get if a token is expired.

_MUST revert if the `tokenId` token does not exist._

#### Parameters

| Name    | Type    | Description                                       |
| ------- | ------- | ------------------------------------------------- |
| tokenId | uint256 | The token for which the expired status is queried |

#### Returns

| Name | Type | Description             |
| ---- | ---- | ----------------------- |
| \_0  | bool | If the token is expired |

### isShadowed

```solidity
function isShadowed(uint256 tokenId) external view returns (bool)
```

Get if a token is shadowed.

_MUST revert if the `tokenId` token does not exists._

#### Parameters

| Name    | Type    | Description        |
| ------- | ------- | ------------------ |
| tokenId | uint256 | The token to query |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### isSoulInSlot

```solidity
function isSoulInSlot(address soul, uint256 slot) external view returns (bool)
```

Check if a soul is in a slot.

_MUST revert if the slot does not exist._

#### Parameters

| Name | Type    | Description                                         |
| ---- | ------- | --------------------------------------------------- |
| soul | address | The soul whose existence in the slot is queried for |
| slot | uint256 | The slot whose existence of the soul is queried for |

#### Returns

| Name | Type | Description                                          |
| ---- | ---- | ---------------------------------------------------- |
| \_0  | bool | True if the `soul` is in the `slot`, false otherwise |

### isValid

```solidity
function isValid(uint256 tokenId) external view returns (bool)
```

Get the validity of a token.

_MUST revert if the `tokenId` does not exist_

#### Parameters

| Name    | Type    | Description                               |
| ------- | ------- | ----------------------------------------- |
| tokenId | uint256 | the token for which to query the validity |

#### Returns

| Name | Type | Description           |
| ---- | ---- | --------------------- |
| \_0  | bool | If the token is valid |

### issuerOf

```solidity
function issuerOf(uint256 tokenId) external view returns (address)
```

Get the issuer of a token.

_MUST revert if the `tokenId` does not exist_

#### Parameters

| Name    | Type    | Description                             |
| ------- | ------- | --------------------------------------- |
| tokenId | uint256 | the token for which to query the issuer |

#### Returns

| Name | Type    | Description                            |
| ---- | ------- | -------------------------------------- |
| \_0  | address | The address of the issuer of `tokenId` |

### mint

```solidity
function mint(address soul, uint256 value, uint256 slot, uint256 expiryDate, bool shadowed) external nonpayable
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| soul       | address | undefined   |
| value      | uint256 | undefined   |
| slot       | uint256 | undefined   |
| expiryDate | uint256 | undefined   |
| shadowed   | bool    | undefined   |

### mintBatch

```solidity
function mintBatch(address[] souls, uint256 value, uint256 slot, uint256 expiryDate, bool shadowed) external nonpayable
```

#### Parameters

| Name       | Type      | Description |
| ---------- | --------- | ----------- |
| souls      | address[] | undefined   |
| value      | uint256   | undefined   |
| slot       | uint256   | undefined   |
| expiryDate | uint256   | undefined   |
| shadowed   | bool      | undefined   |

### mintDelegate

```solidity
function mintDelegate(address operator, uint256 delegateRequestId) external nonpayable
```

Delegate a one-time minting right to `operator` for `delegateRequestId` delegate request.

_MUST revert if the caller does not have the right to delegate._

#### Parameters

| Name              | Type    | Description                                                                   |
| ----------------- | ------- | ----------------------------------------------------------------------------- |
| operator          | address | The soul to which the minting right is delegated                              |
| delegateRequestId | uint256 | The delegate request describing the soul, value and slot of the token to mint |

### mintDelegateBatch

```solidity
function mintDelegateBatch(address[] operators, uint256[] delegateRequestIds) external nonpayable
```

Delegate one-time minting rights to `operators` for corresponding delegate request in `delegateRequestIds`.

_MUST revert if the caller does not have the right to delegate. MUST revert if the length of `operators` and `delegateRequestIds` do not match._

#### Parameters

| Name               | Type      | Description                                                                     |
| ------------------ | --------- | ------------------------------------------------------------------------------- |
| operators          | address[] | The souls to which the minting right is delegated                               |
| delegateRequestIds | uint256[] | The delegate requests describing the soul, value and slot of the tokens to mint |

### name

```solidity
function name() external view returns (string)
```

Get the name of the contract.

#### Returns

| Name | Type   | Description              |
| ---- | ------ | ------------------------ |
| \_0  | string | The name of the contract |

### owner

```solidity
function owner() external view returns (address)
```

_Returns the address of the current owner._

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### recover

```solidity
function recover(address soul, bytes signature) external nonpayable
```

Recover the tokens of `soul` with `signature`.

_MUST revert if the signature is invalid._

#### Parameters

| Name      | Type    | Description                         |
| --------- | ------- | ----------------------------------- |
| soul      | address | The soul whose tokens are recovered |
| signature | bytes   | The signature signed by the `soul`  |

### removeApprovalRequest

```solidity
function removeApprovalRequest(uint256 approvalRequestId) external nonpayable
```

Remove `approvalRequestId` approval request.

_MUST revert if the caller is not the creator of the approval request._

#### Parameters

| Name              | Type    | Description                    |
| ----------------- | ------- | ------------------------------ |
| approvalRequestId | uint256 | The approval request to remove |

### removeDelegateRequest

```solidity
function removeDelegateRequest(uint256 delegateRequestId) external nonpayable
```

Remove a delegate request.

_MUST revert if the delegate request does not exists. MUST revert if the caller is not the creator of the delegate request._

#### Parameters

| Name              | Type    | Description                     |
| ----------------- | ------- | ------------------------------- |
| delegateRequestId | uint256 | The delegate request to remove. |

### removeVoter

```solidity
function removeVoter(address voter) external nonpayable
```

Remove the `voter` from the contract.

_MUST revert if the caller is not an administrator. MUST revert if `voter` is not a voter._

#### Parameters

| Name  | Type    | Description         |
| ----- | ------- | ------------------- |
| voter | address | the voter to remove |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```

_Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner._

### renounceRole

```solidity
function renounceRole(bytes32 role, address account) external nonpayable
```

_Revokes `role` from the calling account. Roles are often managed via {grantRole} and {revokeRole}: this function&#39;s purpose is to provide a mechanism for accounts to lose their privileges if they are compromised (such as when a trusted device is misplaced). If the calling account had been revoked `role`, emits a {RoleRevoked} event. Requirements: - the caller must be `account`. May emit a {RoleRevoked} event._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| role    | bytes32 | undefined   |
| account | address | undefined   |

### reveal

```solidity
function reveal(uint256 tokenId) external nonpayable
```

Reveal a token.

_MUST revert if the `tokenId` token does not exists._

#### Parameters

| Name    | Type    | Description         |
| ------- | ------- | ------------------- |
| tokenId | uint256 | The token to reveal |

### revoke

```solidity
function revoke(uint256 tokenId) external nonpayable
```

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

### revokeBatch

```solidity
function revokeBatch(uint256[] tokenIds) external nonpayable
```

#### Parameters

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| tokenIds | uint256[] | undefined   |

### revokeDelegate

```solidity
function revokeDelegate(address operator, uint256 tokenId) external nonpayable
```

Delegate a one-time revoking right to `operator` for `tokenId` token.

_MUST revert if the caller does not have the right to delegate._

#### Parameters

| Name     | Type    | Description                                       |
| -------- | ------- | ------------------------------------------------- |
| operator | address | The soul to which the revoking right is delegated |
| tokenId  | uint256 | The token to revoke                               |

### revokeDelegateBatch

```solidity
function revokeDelegateBatch(address[] operators, uint256[] tokenIds) external nonpayable
```

Delegate one-time minting rights to `operators` for corresponding token in `tokenIds`.

_MUST revert if the caller does not have the right to delegate. MUST revert if the length of `operators` and `tokenIds` do not match._

#### Parameters

| Name      | Type      | Description                                        |
| --------- | --------- | -------------------------------------------------- |
| operators | address[] | The souls to which the revoking right is delegated |
| tokenIds  | uint256[] | The tokens to revoke                               |

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external nonpayable
```

_Revokes `role` from `account`. If `account` had been granted `role`, emits a {RoleRevoked} event. Requirements: - the caller must have `role`&#39;s admin role. May emit a {RoleRevoked} event._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| role    | bytes32 | undefined   |
| account | address | undefined   |

### setBatchExpiryDates

```solidity
function setBatchExpiryDates(uint256[] tokenIds, uint256[] dates) external nonpayable
```

Set the expiry date of multiple tokens.

_MUST revert if the `tokenIds` tokens does not exist. MUST revert if the `dates` is in the past. MUST revert if the length of `tokenIds` and `dates` do not match._

#### Parameters

| Name     | Type      | Description                           |
| -------- | --------- | ------------------------------------- |
| tokenIds | uint256[] | The tokens whose expiry dates are set |
| dates    | uint256[] | The expire dates to set               |

### setExpiryDate

```solidity
function setExpiryDate(uint256 tokenId, uint256 date) external nonpayable
```

Set the expiry date of a token.

_MUST revert if the `tokenId` token does not exist. MUST revert if the `date` is in the past._

#### Parameters

| Name    | Type    | Description                        |
| ------- | ------- | ---------------------------------- |
| tokenId | uint256 | The token whose expiry date is set |
| date    | uint256 | The expire date to set             |

### shadow

```solidity
function shadow(uint256 tokenId) external nonpayable
```

Shadow a token.

_MUST revert if the `tokenId` token does not exists._

#### Parameters

| Name    | Type    | Description         |
| ------- | ------- | ------------------- |
| tokenId | uint256 | The token to shadow |

### slotByIndex

```solidity
function slotByIndex(uint256 index) external view returns (uint256)
```

Get the slot with `index` among all the slots.

_MUST revert if the `index` exceed the total number of slots._

#### Parameters

| Name  | Type    | Description                       |
| ----- | ------- | --------------------------------- |
| index | uint256 | The index of the slot queried for |

#### Returns

| Name | Type    | Description             |
| ---- | ------- | ----------------------- |
| \_0  | uint256 | The slot is queried for |

### slotCount

```solidity
function slotCount() external view returns (uint256)
```

Get the total number of slots.

#### Returns

| Name | Type    | Description                |
| ---- | ------- | -------------------------- |
| \_0  | uint256 | The total number of slots. |

### slotCountOfSoul

```solidity
function slotCountOfSoul(address soul) external view returns (uint256)
```

Get the number of slots of a soul.

#### Parameters

| Name | Type    | Description                                   |
| ---- | ------- | --------------------------------------------- |
| soul | address | The soul whose number of slots is queried for |

#### Returns

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| \_0  | uint256 | The number of slots of the `soul` |

### slotOf

```solidity
function slotOf(uint256 tokenId) external view returns (uint256)
```

Get the slot of a token.

_MUST revert if the `tokenId` does not exist_

#### Parameters

| Name    | Type    | Description                           |
| ------- | ------- | ------------------------------------- |
| tokenId | uint256 | the token for which to query the slot |

#### Returns

| Name | Type    | Description           |
| ---- | ------- | --------------------- |
| \_0  | uint256 | The slot of `tokenId` |

### slotOfDelegateRequest

```solidity
function slotOfDelegateRequest(uint256 delegateRequestId) external view returns (uint256)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| delegateRequestId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### slotOfSoulByIndex

```solidity
function slotOfSoulByIndex(address soul, uint256 index) external view returns (uint256)
```

Get the slot with `index` of the `soul`.

_MUST revert if the `index` exceed the number of slots of the `soul`._

#### Parameters

| Name  | Type    | Description                         |
| ----- | ------- | ----------------------------------- |
| soul  | address | The soul whose slot is queried for. |
| index | uint256 | The index of the slot queried for   |

#### Returns

| Name | Type    | Description             |
| ---- | ------- | ----------------------- |
| \_0  | uint256 | The slot is queried for |

### slotURI

```solidity
function slotURI(uint256 slot) external view returns (string)
```

Get the URI of a slot.

_MUST revert if the `slot` does not exist._

#### Parameters

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| slot | uint256 | The slot whose URI is queried for |

#### Returns

| Name | Type   | Description           |
| ---- | ------ | --------------------- |
| \_0  | string | The URI of the `slot` |

### soulInSlotByIndex

```solidity
function soulInSlotByIndex(uint256 slot, uint256 index) external view returns (address)
```

Get the soul with `index` of the `slot`.

_MUST revert if the `index` exceed the number of souls in the `slot`._

#### Parameters

| Name  | Type    | Description                         |
| ----- | ------- | ----------------------------------- |
| slot  | uint256 | The slot whose soul is queried for. |
| index | uint256 | The index of the soul queried for   |

#### Returns

| Name | Type    | Description             |
| ---- | ------- | ----------------------- |
| \_0  | address | The soul is queried for |

### soulOf

```solidity
function soulOf(uint256 tokenId) external view returns (address)
```

Get the owner soul of a token.

_MUST revert if the `tokenId` does not exist_

#### Parameters

| Name    | Type    | Description                                 |
| ------- | ------- | ------------------------------------------- |
| tokenId | uint256 | the token for which to query the owner soul |

#### Returns

| Name | Type    | Description                                |
| ---- | ------- | ------------------------------------------ |
| \_0  | address | The address of the owner soul of `tokenId` |

### soulOfDelegateRequest

```solidity
function soulOfDelegateRequest(uint256 delegateRequestId) external view returns (address)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| delegateRequestId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### soulsCount

```solidity
function soulsCount() external view returns (uint256)
```

Get the total number of souls.

#### Returns

| Name | Type    | Description               |
| ---- | ------- | ------------------------- |
| \_0  | uint256 | The total number of souls |

### soulsInSlot

```solidity
function soulsInSlot(uint256 slot) external view returns (uint256)
```

Get the number of souls in a slot.

_MUST revert if the slot does not exist._

#### Parameters

| Name | Type    | Description                                   |
| ---- | ------- | --------------------------------------------- |
| slot | uint256 | The slot whose number of souls is queried for |

#### Returns

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| \_0  | uint256 | The number of souls in the `slot` |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```

#### Parameters

| Name        | Type   | Description |
| ----------- | ------ | ----------- |
| interfaceId | bytes4 | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### symbol

```solidity
function symbol() external view returns (string)
```

Get the symbol of the contract.

#### Returns

| Name | Type   | Description                |
| ---- | ------ | -------------------------- |
| \_0  | string | The symbol of the contract |

### tokenByIndex

```solidity
function tokenByIndex(uint256 index) external view returns (uint256)
```

Get the tokenId with `index` of all the tokens.

_MUST revert if the `index` exceed the total number of tokens._

#### Parameters

| Name  | Type    | Description                        |
| ----- | ------- | ---------------------------------- |
| index | uint256 | The index of the token queried for |

#### Returns

| Name | Type    | Description              |
| ---- | ------- | ------------------------ |
| \_0  | uint256 | The token is queried for |

### tokenInSlotByIndex

```solidity
function tokenInSlotByIndex(uint256 slot, uint256 index) external view returns (uint256)
```

Get the tokenId with `index` of the `slot`.

_MUST revert if the `index` exceed the number of tokens in the `slot`._

#### Parameters

| Name  | Type    | Description                          |
| ----- | ------- | ------------------------------------ |
| slot  | uint256 | The slot whose token is queried for. |
| index | uint256 | The index of the token queried for   |

#### Returns

| Name | Type    | Description              |
| ---- | ------- | ------------------------ |
| \_0  | uint256 | The token is queried for |

### tokenOf

```solidity
function tokenOf(uint256 tokenId) external view returns (struct ERC5727.Token)
```

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type          | Description |
| ---- | ------------- | ----------- |
| \_0  | ERC5727.Token | undefined   |

### tokenOfSoulByIndex

```solidity
function tokenOfSoulByIndex(address soul, uint256 index) external view returns (uint256)
```

Get the tokenId with `index` of the `soul`.

_MUST revert if the `index` exceed the number of tokens owned by the `soul`._

#### Parameters

| Name  | Type    | Description                          |
| ----- | ------- | ------------------------------------ |
| soul  | address | The soul whose token is queried for. |
| index | uint256 | The index of the token queried for   |

#### Returns

| Name | Type    | Description              |
| ---- | ------- | ------------------------ |
| \_0  | uint256 | The token is queried for |

### tokenSupplyInSlot

```solidity
function tokenSupplyInSlot(uint256 slot) external view returns (uint256)
```

Get the number of tokens in a slot.

_MUST revert if the slot does not exist._

#### Parameters

| Name | Type    | Description                                    |
| ---- | ------- | ---------------------------------------------- |
| slot | uint256 | The slot whose number of tokens is queried for |

#### Returns

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| \_0  | uint256 | The number of tokens in the `slot` |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```

Get the URI of a token.

_MUST revert if the `tokenId` token does not exist._

#### Parameters

| Name    | Type    | Description                        |
| ------- | ------- | ---------------------------------- |
| tokenId | uint256 | The token whose URI is queried for |

#### Returns

| Name | Type   | Description                    |
| ---- | ------ | ------------------------------ |
| \_0  | string | The URI of the `tokenId` token |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```

_Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner._

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| newOwner | address | undefined   |

### valueOf

```solidity
function valueOf(uint256 tokenId) external view returns (uint256)
```

Get the value of a token.

_MUST revert if the `tokenId` does not exist_

#### Parameters

| Name    | Type    | Description                              |
| ------- | ------- | ---------------------------------------- |
| tokenId | uint256 | the token for which to query the balance |

#### Returns

| Name | Type    | Description            |
| ---- | ------- | ---------------------- |
| \_0  | uint256 | The value of `tokenId` |

### valueOfDelegateRequest

```solidity
function valueOfDelegateRequest(uint256 delegateRequestId) external view returns (uint256)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| delegateRequestId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### valueOf\_

```solidity
function valueOf_(uint256 tokenId) external nonpayable returns (uint256)
```

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### voters

```solidity
function voters() external view returns (address[])
```

Get the voters of the contract.

#### Returns

| Name | Type      | Description             |
| ---- | --------- | ----------------------- |
| \_0  | address[] | The array of the voters |

## Events

### Charged

```solidity
event Charged(uint256 indexed tokenId, uint256 value)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| tokenId `indexed` | uint256 | undefined   |
| value             | uint256 | undefined   |

### Consumed

```solidity
event Consumed(uint256 indexed tokenId, uint256 value)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| tokenId `indexed` | uint256 | undefined   |
| value             | uint256 | undefined   |

### Destroyed

```solidity
event Destroyed(address indexed soul, uint256 indexed tokenId)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| soul `indexed`    | address | undefined   |
| tokenId `indexed` | uint256 | undefined   |

### Minted

```solidity
event Minted(address indexed soul, uint256 indexed tokenId, uint256 value)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| soul `indexed`    | address | undefined   |
| tokenId `indexed` | uint256 | undefined   |
| value             | uint256 | undefined   |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```

#### Parameters

| Name                    | Type    | Description |
| ----------------------- | ------- | ----------- |
| previousOwner `indexed` | address | undefined   |
| newOwner `indexed`      | address | undefined   |

### Revoked

```solidity
event Revoked(address indexed soul, uint256 indexed tokenId)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| soul `indexed`    | address | undefined   |
| tokenId `indexed` | uint256 | undefined   |

### RoleAdminChanged

```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole)
```

#### Parameters

| Name                        | Type    | Description |
| --------------------------- | ------- | ----------- |
| role `indexed`              | bytes32 | undefined   |
| previousAdminRole `indexed` | bytes32 | undefined   |
| newAdminRole `indexed`      | bytes32 | undefined   |

### RoleGranted

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| role `indexed`    | bytes32 | undefined   |
| account `indexed` | address | undefined   |
| sender `indexed`  | address | undefined   |

### RoleRevoked

```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| role `indexed`    | bytes32 | undefined   |
| account `indexed` | address | undefined   |
| sender `indexed`  | address | undefined   |

### SlotAdded

```solidity
event SlotAdded(uint256 indexed slot, uint256 maxSupply)
```

#### Parameters

| Name           | Type    | Description |
| -------------- | ------- | ----------- |
| slot `indexed` | uint256 | undefined   |
| maxSupply      | uint256 | undefined   |

### SlotChanged

```solidity
event SlotChanged(uint256 indexed tokenId, uint256 indexed oldSlot, uint256 indexed newSlot)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| tokenId `indexed` | uint256 | undefined   |
| oldSlot `indexed` | uint256 | undefined   |
| newSlot `indexed` | uint256 | undefined   |
