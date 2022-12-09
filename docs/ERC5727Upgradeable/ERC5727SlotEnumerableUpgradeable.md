# ERC5727SlotEnumerableUpgradeable

## Methods

### DEFAULT_ADMIN_ROLE

```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32)
```

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | bytes32 | undefined   |

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

### contractURI

```solidity
function contractURI() external view returns (string)
```

Get the URI of the contract.

#### Returns

| Name | Type   | Description             |
| ---- | ------ | ----------------------- |
| \_0  | string | The URI of the contract |

### emittedCount

```solidity
function emittedCount() external view returns (uint256)
```

Get the total number of tokens emitted.

#### Returns

| Name | Type    | Description                        |
| ---- | ------- | ---------------------------------- |
| \_0  | uint256 | The total number of tokens emitted |

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

### Initialized

```solidity
event Initialized(uint8 version)
```

#### Parameters

| Name    | Type  | Description |
| ------- | ----- | ----------- |
| version | uint8 | undefined   |

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
