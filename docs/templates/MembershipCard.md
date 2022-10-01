# MembershipCard

## Methods

### approveMint

```solidity
function approveMint(address owner) external nonpayable
```

Cast a vote to mint a token for a specific address

#### Parameters

| Name  | Type    | Description                        |
| ----- | ------- | ---------------------------------- |
| owner | address | Address for whom to mint the token |

### approveRevoke

```solidity
function approveRevoke(uint256 tokenId) external nonpayable
```

Cast a vote to revoke a token for a specific address

#### Parameters

| Name    | Type    | Description                       |
| ------- | ------- | --------------------------------- |
| tokenId | uint256 | Identifier of the token to revoke |

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
| operators | address[] | Addresses allowed to mint a token                          |
| owners    | address[] | Addresses for whom `operators` are allowed to mint a token |

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

### isDelegate

```solidity
function isDelegate(address operator, address owner) external view returns (bool)
```

Check if an operator is a delegate for a given address

#### Parameters

| Name     | Type    | Description                      |
| -------- | ------- | -------------------------------- |
| operator | address | Address of the operator          |
| owner    | address | Address of the token&#39;s owner |

#### Returns

| Name | Type | Description                                                       |
| ---- | ---- | ----------------------------------------------------------------- |
| \_0  | bool | True if the `operator` is a delegate for `owner`, false otherwise |

### isDelegateOf

```solidity
function isDelegateOf(address owner) external view returns (bool)
```

Check if you are a delegate for a given address

#### Parameters

| Name  | Type    | Description                      |
| ----- | ------- | -------------------------------- |
| owner | address | Address of the token&#39;s owner |

#### Returns

| Name | Type | Description                                                   |
| ---- | ---- | ------------------------------------------------------------- |
| \_0  | bool | True if the caller is a delegate for `owner`, false otherwise |

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

### name

```solidity
function name() external view returns (string)
```

#### Returns

| Name | Type   | Description                                     |
| ---- | ------ | ----------------------------------------------- |
| \_0  | string | Descriptive name of the tokens in this contract |

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

#### Returns

| Name | Type   | Description                                        |
| ---- | ------ | -------------------------------------------------- |
| \_0  | string | An abbreviated name of the tokens in this contract |

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

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```

URI to query to get the token&#39;s metadata

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| tokenId | uint256 | Identifier of the token |

#### Returns

| Name | Type   | Description       |
| ---- | ------ | ----------------- |
| \_0  | string | URI for the token |

### voters

```solidity
function voters() external view returns (address[])
```

Get voters addresses for this consensus contract

#### Returns

| Name | Type      | Description             |
| ---- | --------- | ----------------------- |
| \_0  | address[] | Addresses of the voters |

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
