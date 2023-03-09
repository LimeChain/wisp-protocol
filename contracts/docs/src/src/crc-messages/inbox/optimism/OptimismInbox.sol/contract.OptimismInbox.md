# OptimismInbox
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/crc-messages/inbox/optimism/OptimismInbox.sol)

**Inherits:**
[CRCInbox](/src/crc-messages/CRCInbox.sol/contract.CRCInbox.md), L2OptimismBedrockStateProver

**Author:**
Perseverance

Inbox contract for Optimism Bedrock rollups like Optimism and Base


## Functions
### constructor


```solidity
constructor(address _lightClient, address _oracleAddress) L2OptimismBedrockStateProver(_lightClient, _oracleAddress);
```

### receiveMessage

Method to trigger the receiving of a CRC message

*calls the target contract with the message but does not revert even if the target call reverts.*


```solidity
function receiveMessage(
    CRCTypes.CRCMessageEnvelope calldata envelope,
    uint64 blockNumber,
    uint256 outputIndex,
    OptimismTypes.OutputRootMPTProof calldata outputProof,
    OptimismTypes.MPTInclusionProof calldata inclusionProof
) public virtual returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`envelope`|`CRCMessageEnvelope.CRCTypes`|The envelope of the message that is being relayed|
|`blockNumber`|`uint64`|The block number to request the L1 state root for|
|`outputIndex`|`uint256`|The index to find the output proof at inside the Bedrock OutputOracle|
|`outputProof`|`OutputRootMPTProof.OptimismTypes`|The MPT proof data to verify that the given Optimism output root is contained inside the OutputOracle for the expected index|
|`inclusionProof`|`MPTInclusionProof.OptimismTypes`|The MPT proof data to verify that the given data is contained at a given slot inside Optimism|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`success`|`bool`|if the output root is indeed there|


