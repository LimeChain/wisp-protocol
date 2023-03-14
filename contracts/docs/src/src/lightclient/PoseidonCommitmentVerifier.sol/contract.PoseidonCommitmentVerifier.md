# PoseidonCommitmentVerifier
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/PoseidonCommitmentVerifier.sol)


## Functions
### poseidonCommitmentVerifyingKey


```solidity
function poseidonCommitmentVerifyingKey() internal pure returns (PoseidonCommitmentVerifyingKey memory vk);
```

### verifyPoseidonCommitmentMapping


```solidity
function verifyPoseidonCommitmentMapping(uint256[] memory input, PoseidonCommitmentProof memory proof)
    internal
    view
    returns (uint256);
```

### verifyCommitmentMappingProof


```solidity
function verifyCommitmentMappingProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[33] memory input
) public view returns (bool r);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`r`|`bool`| bool true if proof is valid|


## Structs
### PoseidonCommitmentVerifyingKey

```solidity
struct PoseidonCommitmentVerifyingKey {
    Pairing.G1Point alfa1;
    Pairing.G2Point beta2;
    Pairing.G2Point gamma2;
    Pairing.G2Point delta2;
    Pairing.G1Point[] IC;
}
```

### PoseidonCommitmentProof

```solidity
struct PoseidonCommitmentProof {
    Pairing.G1Point A;
    Pairing.G2Point B;
    Pairing.G1Point C;
}
```

