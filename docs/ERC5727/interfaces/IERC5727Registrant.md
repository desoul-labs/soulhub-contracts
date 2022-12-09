# IERC5727Registrant

interfaceId = 0x0349722d

## Methods

### deregister

```solidity
function deregister(address registry) external nonpayable returns (uint256)
```

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| registry | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### isRegistered

```solidity
function isRegistered(address registry) external view returns (bool)
```

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| registry | address | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### register

```solidity
function register(address registry) external nonpayable returns (uint256)
```

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| registry | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

## Events

### Deregistered

```solidity
event Deregistered(address indexed registry)
```

#### Parameters

| Name               | Type    | Description |
| ------------------ | ------- | ----------- |
| registry `indexed` | address | undefined   |

### Registered

```solidity
event Registered(address indexed registry)
```

#### Parameters

| Name               | Type    | Description |
| ------------------ | ------- | ----------- |
| registry `indexed` | address | undefined   |
