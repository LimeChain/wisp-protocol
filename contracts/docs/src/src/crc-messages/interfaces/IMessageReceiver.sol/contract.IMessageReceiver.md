# IMessageReceiver
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/crc-messages/interfaces/IMessageReceiver.sol)

**Author:**
Perseverance

Interface that the contracts receiving messages should implement


## Functions
### receiveMessage

receives CRCMessageEnvelope


```solidity
function receiveMessage(Types.CRCMessageEnvelope calldata envelope, uint256 sourceChainId)
    external
    returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`envelope`|`CRCMessageEnvelope.Types`|the message envelope you are receiving|
|`sourceChainId`|`uint256`||


