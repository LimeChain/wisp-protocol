# Overview
The contracts in here are the foundation for the wisp protocol.
```ml
crc-messages
├─ CRCInbox — "Abstract contract used as foundation for an inbox. Adds common functions and mappings."
├─ CRCOutbox — "Defines an outbox whose elements gets proven inside the destination rollup."
├─ libraries
|  ├─ Types - "Contains the messages types used within the protocol."
├─ interfaces
|  ├─ ICRCOutbox - "Interface for external contracts to work with the outbox"
|  ├─ IMessageReceiver - "Interface that the contracts receiving messages should implement"
├─ inbox
|  ├─ optimism
|    ├─ OptimismInbox - "Inbox contract for Optimism Bedrock rollups like Optimism and Base"
lightclient
├─ BeaconLightClient — ""
├─ BLSAggregatedSignatureVerifier — ""
├─ PoseidonCommitmentVerifier — ""
├─ Structs — ""
├─ interfaces
|  ├─ IBeaconLightClient - ""
├─ libraries
|  ├─ Pairing - ""
|  ├─ SimpleSerialize - ""
```