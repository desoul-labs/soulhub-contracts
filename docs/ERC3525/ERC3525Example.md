# ERC3525Example

This is a demo contract for how to generate slot

## Methods

### allowance

```solidity
function allowance(uint256 tokenId_, address operator_) external view returns (uint256)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| tokenId\_  | uint256 | undefined   |
| operator\_ | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```

_See {IERC721-approve}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### approve

```solidity
function approve(uint256 tokenId_, address to_, uint256 value_) external payable
```

#### Parameters

| Name      | Type    | Description |
| --------- | ------- | ----------- |
| tokenId\_ | uint256 | undefined   |
| to\_      | address | undefined   |
| value\_   | uint256 | undefined   |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```

_See {IERC721-balanceOf}._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### balanceOf

```solidity
function balanceOf(uint256 tokenId_) external view returns (uint256)
```

#### Parameters

| Name      | Type    | Description |
| --------- | ------- | ----------- |
| tokenId\_ | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### contractURI

```solidity
function contractURI() external view returns (string)
```

Returns the Uniform Resource Identifier (URI) for the current ERC3525 contract.

_This function SHOULD return the URI for this contract in JSON format, starting with header `data:application/json;`. See https://eips.ethereum.org/EIPS/eip-3525 for the JSON schema for contract URI._

#### Returns

| Name | Type   | Description                                            |
| ---- | ------ | ------------------------------------------------------ |
| \_0  | string | The JSON formatted URI of the current ERC3525 contract |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```

_See {IERC721-getApproved}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### getSlotDetail

```solidity
function getSlotDetail(uint256 slot_) external view returns (struct ERC3525Example.SlotDetail)
```

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| slot\_ | uint256 | undefined   |

#### Returns

| Name | Type                      | Description |
| ---- | ------------------------- | ----------- |
| \_0  | ERC3525Example.SlotDetail | undefined   |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```

_See {IERC721-isApprovedForAll}._

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| owner    | address | undefined   |
| operator | address | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### mint

```solidity
function mint(string slotName_, string slotDescription_, string slotImage_, uint256 tokenId_, address underlying_, uint8 vestingType_, uint32 maturity_, uint32 term_, uint256 value_) external nonpayable
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| slotName\_        | string  | undefined   |
| slotDescription\_ | string  | undefined   |
| slotImage\_       | string  | undefined   |
| tokenId\_         | uint256 | undefined   |
| underlying\_      | address | undefined   |
| vestingType\_     | uint8   | undefined   |
| maturity\_        | uint32  | undefined   |
| term\_            | uint32  | undefined   |
| value\_           | uint256 | undefined   |

### name

```solidity
function name() external view returns (string)
```

_See {IERC721Metadata-name}._

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```

_See {IERC721-ownerOf}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_See {IERC721-safeTransferFrom}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external nonpayable
```

_See {IERC721-safeTransferFrom}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |
| data    | bytes   | undefined   |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```

_See {IERC721-setApprovalForAll}._

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| operator | address | undefined   |
| approved | bool    | undefined   |

### slotOf

```solidity
function slotOf(uint256 tokenId_) external view returns (uint256)
```

#### Parameters

| Name      | Type    | Description |
| --------- | ------- | ----------- |
| tokenId\_ | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### slotURI

```solidity
function slotURI(uint256 slot_) external view returns (string)
```

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| slot\_ | uint256 | undefined   |

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

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

_See {IERC721Metadata-symbol}._

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### tokenByIndex

```solidity
function tokenByIndex(uint256 index) external view returns (uint256)
```

_See {IERC721Enumerable-tokenByIndex}._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| index | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### tokenOfOwnerByIndex

```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256)
```

_See {IERC721Enumerable-tokenOfOwnerByIndex}._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |
| index | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```

_See {IERC721Metadata-tokenURI}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

_See {IERC721Enumerable-totalSupply}._

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### transferFrom

```solidity
function transferFrom(uint256 fromTokenId_, address to_, uint256 value_) external payable returns (uint256)
```

#### Parameters

| Name          | Type    | Description |
| ------------- | ------- | ----------- |
| fromTokenId\_ | uint256 | undefined   |
| to\_          | address | undefined   |
| value\_       | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_See {IERC721-transferFrom}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### transferFrom

```solidity
function transferFrom(uint256 fromTokenId_, uint256 toTokenId_, uint256 value_) external payable
```

#### Parameters

| Name          | Type    | Description |
| ------------- | ------- | ----------- |
| fromTokenId\_ | uint256 | undefined   |
| toTokenId\_   | uint256 | undefined   |
| value\_       | uint256 | undefined   |

### valueDecimals

```solidity
function valueDecimals() external view returns (uint8)
```

Get the number of decimals the token uses for value - e.g. 6, means the user representation of the value of a token can be calculated by dividing it by 1,000,000. Considering the compatibility with third-party wallets, this function is defined as `valueDecimals()` instead of `decimals()` to avoid conflict with ERC20 tokens.

#### Returns

| Name | Type  | Description                      |
| ---- | ----- | -------------------------------- |
| \_0  | uint8 | The number of decimals for value |

## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```

#### Parameters

| Name               | Type    | Description |
| ------------------ | ------- | ----------- |
| owner `indexed`    | address | undefined   |
| approved `indexed` | address | undefined   |
| tokenId `indexed`  | uint256 | undefined   |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```

#### Parameters

| Name               | Type    | Description |
| ------------------ | ------- | ----------- |
| owner `indexed`    | address | undefined   |
| operator `indexed` | address | undefined   |
| approved           | bool    | undefined   |

### ApprovalValue

```solidity
event ApprovalValue(uint256 indexed _tokenId, address indexed _operator, uint256 _value)
```

#### Parameters

| Name                 | Type    | Description |
| -------------------- | ------- | ----------- |
| \_tokenId `indexed`  | uint256 | undefined   |
| \_operator `indexed` | address | undefined   |
| \_value              | uint256 | undefined   |

### SlotChanged

```solidity
event SlotChanged(uint256 indexed _tokenId, uint256 indexed _oldSlot, uint256 indexed _newSlot)
```

#### Parameters

| Name                | Type    | Description |
| ------------------- | ------- | ----------- |
| \_tokenId `indexed` | uint256 | undefined   |
| \_oldSlot `indexed` | uint256 | undefined   |
| \_newSlot `indexed` | uint256 | undefined   |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| from `indexed`    | address | undefined   |
| to `indexed`      | address | undefined   |
| tokenId `indexed` | uint256 | undefined   |

### TransferValue

```solidity
event TransferValue(uint256 indexed _fromTokenId, uint256 indexed _toTokenId, uint256 _value)
```

#### Parameters

| Name                    | Type    | Description |
| ----------------------- | ------- | ----------- |
| \_fromTokenId `indexed` | uint256 | undefined   |
| \_toTokenId `indexed`   | uint256 | undefined   |
| \_value                 | uint256 | undefined   |
