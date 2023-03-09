# CRCInbox
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/crc-messages/CRCInbox.sol)

**Inherits:**
Owned

**Author:**
Perseverance

Abstract contract used as foundation for an inbox. Adds common functions and mappings.


## State Variables
### isUsed
used for marking messages as used and protect against replay


```solidity
mapping(bytes32 => bool) public isUsed;
```


### relayerOf
used for marking the relayer of a certain message


```solidity
mapping(bytes32 => address) public relayerOf;
```


### sourceChainIdFor
Maps address of CRCOutbox in a certain source rollup or chain to its chainId


```solidity
mapping(address => uint256) public sourceChainIdFor;
```


## Functions
### constructor


```solidity
constructor() Owned(msg.sender);
```

### setChainIdFor

Sets the chainid for CRCOutbox


```solidity
function setChainIdFor(address outbox, uint256 chainId) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`outbox`|`address`|the CRCOutbox contract address at the rollup|
|`chainId`|`uint256`|the chainId of the rollup|


### getMessageHash

generates the message hash of the given envelope


```solidity
function getMessageHash(CRCTypes.CRCMessageEnvelope calldata envelope) public pure returns (bytes32 messageHash);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`envelope`|`CRCMessageEnvelope.CRCTypes`|the message to get the hash of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`messageHash`|`bytes32`|the message hash of this envelope|


### getChainID

gets the chainId for this contract network


```solidity
function getChainID() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the chainId|


### markMessageRelayed

marks the message as relayed and stores the relayer

*marks the msg.sender as the relayer*


```solidity
function markMessageRelayed(bytes32 messageHash) internal virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`messageHash`|`bytes32`|the message hash to mark as relayed|


## Events
### InvokeSuccess

```solidity
event InvokeSuccess(address indexed target, bytes32 indexed hash);
```

### InvokeFailure

```solidity
event InvokeFailure(address indexed target, bytes32 indexed hash);
```

### MessageReceived

```solidity
event MessageReceived(address indexed user, address indexed target, bytes32 indexed hash);
```

