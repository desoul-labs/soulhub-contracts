# IERC4671Store

## Methods

### add

```solidity
function add(address token) external nonpayable
```

Add a IERC4671Enumerable contract address to the caller&#39;s record

#### Parameters

| Name  | Type    | Description                                       |
| ----- | ------- | ------------------------------------------------- |
| token | address | Address of the IERC4671Enumerable contract to add |

### get

```solidity
function get(address owner) external view returns (address[])
```

Get all the IERC4671Enumerable contracts for a given owner

#### Parameters

| Name  | Type    | Description                                                    |
| ----- | ------- | -------------------------------------------------------------- |
| owner | address | Address for which to retrieve the IERC4671Enumerable contracts |

#### Returns

| Name | Type      | Description |
| ---- | --------- | ----------- |
| \_0  | address[] | undefined   |

### remove

```solidity
function remove(address token) external nonpayable
```

Remove a IERC4671Enumerable contract from the caller&#39;s record

#### Parameters

| Name  | Type    | Description                                          |
| ----- | ------- | ---------------------------------------------------- |
| token | address | Address of the IERC4671Enumerable contract to remove |

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

### Added

```solidity
event Added(address owner, address token)
```

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |
| token | address | undefined   |

### Removed

```solidity
event Removed(address owner, address token)
```

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |
| token | address | undefined   |
