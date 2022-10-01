# IERC3525SlotApprovable

> ERC-3525 Semi-Fungible Token Standard, optional extension for approval of slot level

_Interfaces for any contract that wants to support approval of slot level, which allows an operator to manage one&#39;s tokens with the same slot. See https://eips.ethereum.org/EIPS/eip-3525 Note: the ERC-165 identifier for this interface is 0xb688be58._

## Methods

### allowance

```solidity
function allowance(uint256 _tokenId, address _operator) external view returns (uint256)
```

Get the maximum value of a token that an operator is allowed to manage.

#### Parameters

| Name       | Type    | Description                                |
| ---------- | ------- | ------------------------------------------ |
| \_tokenId  | uint256 | The token for which to query the allowance |
| \_operator | address | The address of an operator                 |

#### Returns

| Name | Type    | Description                                                                    |
| ---- | ------- | ------------------------------------------------------------------------------ |
| \_0  | uint256 | The current approval value of `_tokenId` that `_operator` is allowed to manage |

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```

_Gives permission to `to` to transfer `tokenId` token to another account. The approval is cleared when the token is transferred. Only a single account can be approved at a time, so approving the zero address clears previous approvals. Requirements: - The caller must own the token or be an approved operator. - `tokenId` must exist. Emits an {Approval} event._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### approve

```solidity
function approve(uint256 _tokenId, address _operator, uint256 _value) external payable
```

Allow an operator to manage the value of a token, up to the `_value` amount.

_MUST revert unless caller is the current owner, an authorized operator, or the approved address for `_tokenId`. MUST emit ApprovalValue event._

#### Parameters

| Name       | Type    | Description                                                             |
| ---------- | ------- | ----------------------------------------------------------------------- |
| \_tokenId  | uint256 | The token to approve                                                    |
| \_operator | address | The operator to be approved                                             |
| \_value    | uint256 | The maximum value of `_toTokenId` that `_operator` is allowed to manage |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256 balance)
```

_Returns the number of tokens in `owner`&#39;s account._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |

#### Returns

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| balance | uint256 | undefined   |

### balanceOf

```solidity
function balanceOf(uint256 _tokenId) external view returns (uint256)
```

Get the value of a token.

#### Parameters

| Name      | Type    | Description                              |
| --------- | ------- | ---------------------------------------- |
| \_tokenId | uint256 | The token for which to query the balance |

#### Returns

| Name | Type    | Description             |
| ---- | ------- | ----------------------- |
| \_0  | uint256 | The value of `_tokenId` |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address operator)
```

_Returns the account approved for `tokenId` token. Requirements: - `tokenId` must exist._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| operator | address | undefined   |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```

_Returns if the `operator` is allowed to manage all of the assets of `owner`. See {setApprovalForAll}_

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| owner    | address | undefined   |
| operator | address | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### isApprovedForSlot

```solidity
function isApprovedForSlot(address _owner, uint256 _slot, address _operator) external view returns (bool)
```

Query if `_operator` is authorized to manage all of `_owner`&#39;s tokens with the specified slot.

#### Parameters

| Name       | Type    | Description                                  |
| ---------- | ------- | -------------------------------------------- |
| \_owner    | address | The address that owns the ERC3525 tokens     |
| \_slot     | uint256 | The slot of tokens being queried approval of |
| \_operator | address | The address for whom to query approval       |

#### Returns

| Name | Type | Description                                                                                             |
| ---- | ---- | ------------------------------------------------------------------------------------------------------- |
| \_0  | bool | True if `_operator` is authorized to manage all of `_owner`&#39;s tokens with `_slot`, false otherwise. |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address owner)
```

_Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients are aware of the ERC721 protocol to prevent tokens from being forever locked. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event._

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

_Safely transfers `tokenId` token from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |
| data    | bytes   | undefined   |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool _approved) external nonpayable
```

_Approve or remove `operator` as an operator for the caller. Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller. Requirements: - The `operator` cannot be the caller. Emits an {ApprovalForAll} event._

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| operator   | address | undefined   |
| \_approved | bool    | undefined   |

### setApprovalForSlot

```solidity
function setApprovalForSlot(address _owner, uint256 _slot, address _operator, bool _approved) external payable
```

Approve or disapprove an operator to manage all of `_owner`&#39;s tokens with the specified slot.

_Caller SHOULD be `_owner` or an operator who has been authorized through `setApprovalForAll`. MUST emit ApprovalSlot event._

#### Parameters

| Name       | Type    | Description                                              |
| ---------- | ------- | -------------------------------------------------------- |
| \_owner    | address | The address that owns the ERC3525 tokens                 |
| \_slot     | uint256 | The slot of tokens being queried approval of             |
| \_operator | address | The address for whom to query approval                   |
| \_approved | bool    | Identify if `_operator` would be approved or disapproved |

### slotOf

```solidity
function slotOf(uint256 _tokenId) external view returns (uint256)
```

Get the slot of a token.

#### Parameters

| Name      | Type    | Description                |
| --------- | ------- | -------------------------- |
| \_tokenId | uint256 | The identifier for a token |

#### Returns

| Name | Type    | Description           |
| ---- | ------- | --------------------- |
| \_0  | uint256 | The slot of the token |

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

### transferFrom

```solidity
function transferFrom(uint256 _fromTokenId, address _to, uint256 _value) external payable returns (uint256)
```

Transfer value from a specified token to an address. The caller should confirm that `_to` is capable of receiving ERC3525 tokens.

_This function MUST create a new ERC3525 token with the same slot for `_to` to receive the transferred value. MUST revert if `_fromTokenId` is zero token id or does not exist. MUST revert if `_to` is zero address. MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the operator. MUST emit `Transfer` and `TransferValue` events._

#### Parameters

| Name          | Type    | Description                      |
| ------------- | ------- | -------------------------------- |
| \_fromTokenId | uint256 | The token to transfer value from |
| \_to          | address | The address to transfer value to |
| \_value       | uint256 | The transferred value            |

#### Returns

| Name | Type    | Description                                                                |
| ---- | ------- | -------------------------------------------------------------------------- |
| \_0  | uint256 | ID of the new token created for `_to` which receives the transferred value |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_Transfers `tokenId` token from `from` to `to`. WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. Emits a {Transfer} event._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### transferFrom

```solidity
function transferFrom(uint256 _fromTokenId, uint256 _toTokenId, uint256 _value) external payable
```

Transfer value from a specified token to another specified token with the same slot.

_Caller MUST be the current owner, an authorized operator or an operator who has been approved the whole `_fromTokenId` or part of it. MUST revert if `_fromTokenId` or `_toTokenId` is zero token id or does not exist. MUST revert if slots of `_fromTokenId` and `_toTokenId` do not match. MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the operator. MUST emit `TransferValue` event._

#### Parameters

| Name          | Type    | Description                      |
| ------------- | ------- | -------------------------------- |
| \_fromTokenId | uint256 | The token to transfer value from |
| \_toTokenId   | uint256 | The token to transfer value to   |
| \_value       | uint256 | The transferred value            |

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

### ApprovalForSlot

```solidity
event ApprovalForSlot(address indexed _owner, uint256 indexed _slot, address indexed _operator, bool _approved)
```

_MUST emits when an operator is approved or disapproved to manage all of `_owner`&#39;s tokens with the same slot._

#### Parameters

| Name                 | Type    | Description                                                                   |
| -------------------- | ------- | ----------------------------------------------------------------------------- |
| \_owner `indexed`    | address | The address whose tokens are approved                                         |
| \_slot `indexed`     | uint256 | The slot to approve, all of `_owner`&#39;s tokens with this slot are approved |
| \_operator `indexed` | address | The operator being approved or disapproved                                    |
| \_approved           | bool    | Identify if `_operator` is approved or disapproved                            |

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
