# LightClientUpdate
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/Structs.sol)


```solidity
struct LightClientUpdate {
    BeaconBlockHeader attestedHeader;
    BeaconBlockHeader finalizedHeader;
    bytes32[] finalityBranch;
    bytes32 nextSyncCommitteeRoot;
    bytes32[] nextSyncCommitteeBranch;
    bytes32 executionStateRoot;
    bytes32[] executionStateRootBranch;
    uint64 blockNumber;
    bytes32[] blockNumberBranch;
    BLSAggregatedSignature signature;
}
```

