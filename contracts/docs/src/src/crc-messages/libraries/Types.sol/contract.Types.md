# Types
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/crc-messages/libraries/Types.sol)

**Author:**
Perseverance

Contains the messages types used within the protocol


## Structs
### CRCMessage
Input structure for sending a CRC message


```solidity
struct CRCMessage {
    uint8 version;
    uint256 destinationChainId;
    uint64 nonce;
    address user;
    address target;
    bytes payload;
    uint256 stateRelayFee;
    uint256 deliveryFee;
    bytes extra;
}
```

### CRCMessageEnvelope
Complete CRCMessage envelop including the sender. Used upon receiving of CRCMessages


```solidity
struct CRCMessageEnvelope {
    CRCMessage message;
    address sender;
}
```

