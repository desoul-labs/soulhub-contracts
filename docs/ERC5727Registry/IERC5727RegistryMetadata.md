# IERC5727RegistryMetadata

## Methods

### addressOf

```solidity
function addressOf(uint256 id) external view returns (address)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| id   | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### deregister

```solidity
function deregister(address addr) external nonpayable returns (uint256)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| addr | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### idOf

```solidity
function idOf(address addr) external view returns (uint256)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| addr | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### isRegistered

```solidity
function isRegistered(address addr) external view returns (bool)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| addr | address | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### register

```solidity
function register(address addr) external nonpayable returns (uint256)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| addr | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### registryURI

```solidity
function registryURI() external view returns (string)
```

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

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

### Deregistered

```solidity
event Deregistered(uint256 indexed id, address indexed addr)
```

#### Parameters

| Name           | Type    | Description |
| -------------- | ------- | ----------- |
| id `indexed`   | uint256 | undefined   |
| addr `indexed` | address | undefined   |

### Registered

```solidity
event Registered(uint256 indexed id, address indexed addr)
```

#### Parameters

| Name           | Type    | Description |
| -------------- | ------- | ----------- |
| id `indexed`   | uint256 | undefined   |
| addr `indexed` | address | undefined   |
