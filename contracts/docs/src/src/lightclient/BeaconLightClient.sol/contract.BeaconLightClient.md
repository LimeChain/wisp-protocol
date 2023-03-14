# BeaconLightClient
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/BeaconLightClient.sol)

**Inherits:**
[PoseidonCommitmentVerifier](/src/lightclient/PoseidonCommitmentVerifier.sol/contract.PoseidonCommitmentVerifier.md), [BLSAggregatedSignatureVerifier](/src/lightclient/BLSAggregatedSignatureVerifier.sol/contract.BLSAggregatedSignatureVerifier.md), Ownable


## State Variables
### GENESIS_VALIDATORS_ROOT

```solidity
bytes32 public immutable GENESIS_VALIDATORS_ROOT;
```


### GENESIS_TIME

```solidity
uint256 public immutable GENESIS_TIME;
```


### SECONDS_PER_SLOT

```solidity
uint256 public immutable SECONDS_PER_SLOT;
```


### active

```solidity
bool public active;
```


### defaultForkVersion

```solidity
bytes4 public defaultForkVersion;
```


### headSlot

```solidity
uint64 public headSlot;
```


### headBlockNumber

```solidity
uint64 public headBlockNumber;
```


### latestSyncCommitteePeriod

```solidity
uint256 public latestSyncCommitteePeriod;
```


### slot2block

```solidity
mapping(uint64 => uint64) public slot2block;
```


### executionStateRoots

```solidity
mapping(uint64 => bytes32) public executionStateRoots;
```


### syncCommitteeRootByPeriod

```solidity
mapping(uint256 => bytes32) public syncCommitteeRootByPeriod;
```


### sszToPoseidon

```solidity
mapping(bytes32 => bytes32) public sszToPoseidon;
```


## Functions
### constructor


```solidity
constructor(
    bytes32 genesisValidatorsRoot,
    uint256 genesisTime,
    uint256 secondsPerSlot,
    bytes4 forkVersion,
    uint256 startSyncCommitteePeriod,
    bytes32 startSyncCommitteeRoot,
    bytes32 startSyncCommitteePoseidon
);
```

### isActive


```solidity
modifier isActive();
```

### verifyLightClientUpdate


```solidity
modifier verifyLightClientUpdate(LightClientUpdate calldata _update);
```

### executionStateRoot


```solidity
function executionStateRoot(uint64 slot) external view returns (bytes32);
```

### update


```solidity
function update(LightClientUpdate calldata update) external isActive verifyLightClientUpdate(update);
```

### _update


```solidity
function _update(LightClientUpdate calldata update) internal;
```

### updateWithSyncCommittee


```solidity
function updateWithSyncCommittee(
    LightClientUpdate calldata update,
    bytes32 nextSyncCommitteePoseidon,
    Groth16Proof calldata commitmentMappingProof
) external isActive verifyLightClientUpdate(update);
```

### _verifyLightClientUpdate


```solidity
function _verifyLightClientUpdate(LightClientUpdate calldata update) internal view;
```

### zkMapSSZToPoseidon


```solidity
function zkMapSSZToPoseidon(bytes32 sszCommitment, bytes32 poseidonCommitment, Groth16Proof calldata proof) internal;
```

### zkBLSVerify


```solidity
function zkBLSVerify(
    bytes32 signingRoot,
    bytes32 syncCommitteeRoot,
    uint256 claimedParticipation,
    Groth16Proof calldata proof
) internal view returns (bool);
```

### getCurrentSlot


```solidity
function getCurrentSlot() internal view returns (uint64);
```

### getSyncCommitteePeriodFromSlot


```solidity
function getSyncCommitteePeriodFromSlot(uint64 slot) internal pure returns (uint64);
```

### setDefaultForkVersion


```solidity
function setDefaultForkVersion(bytes4 forkVersion) public onlyOwner;
```

### setActive


```solidity
function setActive(bool newActive) public onlyOwner;
```

## Events
### HeadUpdate

```solidity
event HeadUpdate(uint64 indexed slot, uint64 indexed blockNumber, bytes32 indexed executionRoot);
```

### SyncCommitteeUpdate

```solidity
event SyncCommitteeUpdate(uint64 indexed period, bytes32 indexed root);
```

