# BLSAggregatedSignatureVerifier
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/BLSAggregatedSignatureVerifier.sol)


## Functions
### signatureVerifyingKey


```solidity
function signatureVerifyingKey() internal pure returns (SignatureVerifyingKey memory vk);
```

### verifySignature


```solidity
function verifySignature(uint256[] memory input, SignatureProof memory proof) internal view returns (uint256);
```

### verifySignatureProof


```solidity
function verifySignatureProof(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[34] memory input
) public view returns (bool r);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`r`|`bool`| bool true if proof is valid|


## Structs
### SignatureVerifyingKey

```solidity
struct SignatureVerifyingKey {
    Pairing.G1Point alfa1;
    Pairing.G2Point beta2;
    Pairing.G2Point gamma2;
    Pairing.G2Point delta2;
    Pairing.G1Point[] IC;
}
```

### SignatureProof

```solidity
struct SignatureProof {
    Pairing.G1Point A;
    Pairing.G2Point B;
    Pairing.G1Point C;
}
```

