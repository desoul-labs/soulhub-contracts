# IERC3525Receiver

> ERC3525 token receiver interface

_Interface for any contract that wants to support safeTransfers from ERC3525 contracts. Note: the ERC-165 identifier for this interface is 0x009ce20b._

## Methods

### onERC3525Received

```solidity
function onERC3525Received(address _operator, uint256 _fromTokenId, uint256 _toTokenId, uint256 _value, bytes _data) external nonpayable returns (bytes4)
```

Handle the receipt of an ERC3525 token value.

_An ERC3525 smart contract MUST call this function on the recipient contract after a value transfer (i.e. `safeTransferFrom(uint256,uint256,uint256,bytes)`). MUST return 0x009ce20b (i.e. `bytes4(keccak256(&#39;onERC3525Received(address,uint256,uint256, uint256,bytes)&#39;))`) if the transfer is accepted. MUST revert or return any value other than 0x009ce20b if the transfer is rejected._

#### Parameters

| Name          | Type    | Description                              |
| ------------- | ------- | ---------------------------------------- |
| \_operator    | address | The address which triggered the transfer |
| \_fromTokenId | uint256 | The token id to transfer value from      |
| \_toTokenId   | uint256 | The token id to transfer value to        |
| \_value       | uint256 | The transferred value                    |
| \_data        | bytes   | Additional data with no specified format |

#### Returns

| Name | Type   | Description                                                                                                              |
| ---- | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| \_0  | bytes4 | `bytes4(keccak256(&#39;onERC3525Received(address,uint256,uint256,uint256,bytes)&#39;))` unless the transfer is rejected. |
