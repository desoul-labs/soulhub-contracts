# IERC5727Governance

> ERC5727 Soulbound Token Consensus Interface

_This extension allows minting and revocation of tokens by community voting. interfaceId = 0x3ba738d1_

## Methods

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

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```

_Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section] to learn more about how these ids are created. This function call must use less than 30 000 gas._

#### Parameters

| Name        | Type   | Description |
| ----------- | ------ | ----------- |
| interfaceId | bytes4 | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

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

### Revoked

```solidity
event Revoked(address indexed soul, uint256 indexed tokenId)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| soul `indexed`    | address | undefined   |
| tokenId `indexed` | uint256 | undefined   |

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
