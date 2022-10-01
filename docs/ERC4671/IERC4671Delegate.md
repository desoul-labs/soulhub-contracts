# IERC4671Delegate

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

### delegate

```solidity
function delegate(address operator, address owner) external nonpayable
```

Grant one-time minting right to `operator` for `owner` An allowed operator can call the function to transfer rights.

#### Parameters

| Name     | Type    | Description                                            |
| -------- | ------- | ------------------------------------------------------ |
| operator | address | Address allowed to mint a token                        |
| owner    | address | Address for whom `operator` is allowed to mint a token |

### delegateBatch

```solidity
function delegateBatch(address[] operators, address[] owners) external nonpayable
```

Grant one-time minting right to a list of `operators` for a corresponding list of `owners` An allowed operator can call the function to transfer rights.

#### Parameters

| Name      | Type      | Description                                                |
| --------- | --------- | ---------------------------------------------------------- |
| operators | address[] | Addresses allowed to mint                                  |
| owners    | address[] | Addresses for whom `operators` are allowed to mint a token |

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

### issuerOf

```solidity
function issuerOf(uint256 tokenId) external view returns (address)
```

Get the issuer of a token

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| tokenId | uint256 | Identifier of the token |

#### Returns

| Name | Type    | Description                  |
| ---- | ------- | ---------------------------- |
| \_0  | address | Address who minted `tokenId` |

### mint

```solidity
function mint(address owner) external nonpayable
```

Mint a token. Caller must have the right to mint for the owner.

#### Parameters

| Name  | Type    | Description                          |
| ----- | ------- | ------------------------------------ |
| owner | address | Address for whom the token is minted |

### mintBatch

```solidity
function mintBatch(address[] owners) external nonpayable
```

Mint tokens to multiple addresses. Caller must have the right to mint for all owners.

#### Parameters

| Name   | Type      | Description                              |
| ------ | --------- | ---------------------------------------- |
| owners | address[] | Addresses for whom the tokens are minted |

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
