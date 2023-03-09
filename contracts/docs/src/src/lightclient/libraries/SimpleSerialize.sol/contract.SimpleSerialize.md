# SimpleSerialize
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/libraries/SimpleSerialize.sol)


## Functions
### toLittleEndian


```solidity
function toLittleEndian(uint256 x) internal pure returns (bytes32);
```

### restoreMerkleRoot


```solidity
function restoreMerkleRoot(bytes32 leaf, uint256 index, bytes32[] memory branch) internal pure returns (bytes32);
```

### isValidMerkleBranch


```solidity
function isValidMerkleBranch(bytes32 leaf, uint256 index, bytes32[] memory branch, bytes32 root)
    internal
    pure
    returns (bool);
```

### sszBeaconBlockHeader


```solidity
function sszBeaconBlockHeader(BeaconBlockHeader memory header) internal pure returns (bytes32);
```

### computeDomain


```solidity
function computeDomain(bytes4 forkVersion, bytes32 genesisValidatorsRoot) internal pure returns (bytes32);
```

### computeSigningRoot


```solidity
function computeSigningRoot(BeaconBlockHeader memory header, bytes4 forkVersion, bytes32 genesisValidatorsRoot)
    internal
    pure
    returns (bytes32);
```

