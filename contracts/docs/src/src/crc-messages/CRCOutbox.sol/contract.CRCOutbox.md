# CRCOutbox
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/crc-messages/CRCOutbox.sol)

**Inherits:**
[ICRCOutbox](/src/crc-messages/interfaces/ICRCOutbox.sol/contract.ICRCOutbox.md)

**Author:**
Perseverance

Contract used for sending messages across rollups.
Defines an outbox whose elements gets proven inside the destination rollup


## State Variables
### outbox
*outbox for messages*


```solidity
bytes32[] public outbox;
```


### rawMessages
*raw version of the messages*


```solidity
Types.CRCMessage[] public rawMessages;
```


### indexOf
*getting index by the message hash*


```solidity
mapping(bytes32 => uint256) public indexOf;
```


### noncesNullifier
*used to nullify nonces*


```solidity
mapping(address => mapping(uint64 => bool)) public noncesNullifier;
```


## Functions
### sendMessage

sends CRC message. Stores it as keccak hash inside the outbox

*Complete properties of a CRC message used for the hash are
uint8 - version
uint256 - destination chainId
uint64  - nonce to use against replay attacks
address - message sender
address - user - actual sender
address - target - the target contract in the destination chain
address - payload - the payload to be delivered to the target contract
address - stateRelayFee - the state relay fee
address - deliveryFee - the delivery fee
address - extra - extra bytes to be interpreted by dapps*


```solidity
function sendMessage(Types.CRCMessage calldata message) public returns (bytes32 messageHash);
```

### getMessageByIndex

Returns the sent message by its index in the outbox


```solidity
function getMessageByIndex(uint256 index) public view returns (Types.CRCMessage memory message);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|- the index in the outbox array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`message`|`CRCMessage.Types`|- the sent message|


