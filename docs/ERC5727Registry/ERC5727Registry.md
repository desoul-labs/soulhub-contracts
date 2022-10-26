# ERC5727Registry

## Methods

### \_deregister

```solidity
function _deregister(address addr) external nonpayable returns (uint256)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| addr | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### \_register

```solidity
function _register(address addr) external nonpayable returns (uint256)
```

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| addr | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

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
