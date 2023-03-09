# ICRCOutbox
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/crc-messages/interfaces/ICRCOutbox.sol)

**Author:**
Perseverance

Interface for external contracts to work with the outbox


## Functions
### outbox

getter for message hashes based on their index


```solidity
function outbox(uint256 outboxIndex) external view returns (bytes32 messageHash);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`outboxIndex`|`uint256`|the index in the outbox of the message whose hash will be returned|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`messageHash`|`bytes32`|the hash of the message for this outboxIndex|


### indexOf

getter for message index based on their hash


```solidity
function indexOf(bytes32 messageHash) external view returns (uint256 outboxIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`messageHash`|`bytes32`|the message hash to get the index of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`outboxIndex`|`uint256`|the index in the outbox of this message hash|


### noncesNullifier

used to check if a nullifier has been used for the specified account


```solidity
function noncesNullifier(address sender, uint64 nonce) external view returns (bool used);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|the sender of message|
|`nonce`|`uint64`|the nullifier for this message|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`used`|`bool`|if the nullifier has been used|


### sendMessage

sends CRCMessage


```solidity
function sendMessage(Types.CRCMessage calldata message) external returns (bytes32 messageHash);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`CRCMessage.Types`|the message to be sent|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`messageHash`|`bytes32`|the hash of the message that was sent|


### getMessageByIndex

gets CRC Message by its index


```solidity
function getMessageByIndex(uint256 index) external view returns (Types.CRCMessage memory message);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|the index of the message in the outbox|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`message`|`CRCMessage.Types`|the raw CRC Message|


## Events
### MessageSent

```solidity
event MessageSent(
    address indexed sender, uint256 indexed destinationChainId, bytes32 indexed hash, uint256 messageIndex
);
```

