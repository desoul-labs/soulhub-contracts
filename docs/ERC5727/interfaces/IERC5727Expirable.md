# IERC5727Expirable

> ERC5727 Soulbound Token Expirable Interface

_This extension allows soulbound tokens to be expired._

## Methods

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
