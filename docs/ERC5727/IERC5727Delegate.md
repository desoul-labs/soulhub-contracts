# IERC5727Delegate

> ERC5727 Soulbound Token Delegate Interface

_This extension allows delegation of (batch) minting and revocation of tokens to operator(s)._

## Methods

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
