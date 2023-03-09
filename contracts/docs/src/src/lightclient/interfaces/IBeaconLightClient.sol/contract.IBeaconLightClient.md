# IBeaconLightClient
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/interfaces/IBeaconLightClient.sol)


## Functions
### head


```solidity
function head() external view returns (uint64);
```

### headers


```solidity
function headers(uint64 slot) external view returns (BeaconBlockHeader memory);
```

### optimisticHead


```solidity
function optimisticHead() external view returns (BeaconBlockHeader memory);
```

### stateRoot


```solidity
function stateRoot(uint64 slot) external view returns (bytes32);
```

### executionStateRoot


```solidity
function executionStateRoot(uint64 slot) external view returns (bytes32);
```

