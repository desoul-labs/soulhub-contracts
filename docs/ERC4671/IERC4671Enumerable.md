# IERC4671Enumerable

## Methods

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```

Count all tokens assigned to an owner

#### Parameters

| Name  | Type    | Description                           |
| ----- | ------- | ------------------------------------- |
| owner | address | Address for whom to query the balance |

#### Returns

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| \_0  | uint256 | Number of tokens owned by `owner` |

### emittedCount

```solidity
function emittedCount() external view returns (uint256)
```

#### Returns

| Name | Type    | Description                           |
| ---- | ------- | ------------------------------------- |
| \_0  | uint256 | emittedCount Number of tokens emitted |

### hasValid

```solidity
function hasValid(address owner) external view returns (bool)
```

Check if an address owns a valid token in the contract

#### Parameters

| Name  | Type    | Description                             |
| ----- | ------- | --------------------------------------- |
| owner | address | Address for whom to check the ownership |

#### Returns

| Name | Type | Description                                        |
| ---- | ---- | -------------------------------------------------- |
| \_0  | bool | True if `owner` has a valid token, false otherwise |

### holdersCount

```solidity
function holdersCount() external view returns (uint256)
```

#### Returns

| Name | Type    | Description                          |
| ---- | ------- | ------------------------------------ |
| \_0  | uint256 | holdersCount Number of token holders |

### isValid

```solidity
function isValid(uint256 tokenId) external view returns (bool)
```

Check if a token hasn&#39;t been revoked

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| tokenId | uint256 | Identifier of the token |

#### Returns

| Name | Type | Description                                 |
| ---- | ---- | ------------------------------------------- |
| \_0  | bool | True if the token is valid, false otherwise |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```

Get owner of a token

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| tokenId | uint256 | Identifier of the token |

#### Returns

| Name | Type    | Description                       |
| ---- | ------- | --------------------------------- |
| \_0  | address | Address of the owner of `tokenId` |

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

### tokenByIndex

```solidity
function tokenByIndex(uint256 index) external view returns (uint256)
```

Get a tokenId by it&#39;s index, where 0 &lt;= index &lt; total()

#### Parameters

| Name  | Type    | Description        |
| ----- | ------- | ------------------ |
| index | uint256 | Index of the token |

#### Returns

| Name | Type    | Description          |
| ---- | ------- | -------------------- |
| \_0  | uint256 | tokenId of the token |

### tokenOfOwnerByIndex

```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256)
```

Get the tokenId of a token using its position in the owner&#39;s list

#### Parameters

| Name  | Type    | Description                       |
| ----- | ------- | --------------------------------- |
| owner | address | Address for whom to get the token |
| index | uint256 | Index of the token                |

#### Returns

| Name | Type    | Description          |
| ---- | ------- | -------------------- |
| \_0  | uint256 | tokenId of the token |

## Events

### Minted

```solidity
event Minted(address owner, uint256 tokenId)
```

Event emitted when a token `tokenId` is minted for `owner`

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| owner   | address | undefined   |
| tokenId | uint256 | undefined   |

### Revoked

```solidity
event Revoked(address owner, uint256 tokenId)
```

Event emitted when token `tokenId` of `owner` is revoked

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| owner   | address | undefined   |
| tokenId | uint256 | undefined   |
