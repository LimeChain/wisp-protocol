# Pairing
[Git Source](https://github.com/LimeChain/crc-protocol/blob/0433ea433f562c1a7a34816f3e2c7926f9fa24dd/src/lightclient/libraries/Pairing.sol)


## Functions
### P1


```solidity
function P1() internal pure returns (G1Point memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`G1Point`|the generator of G1|


### P2


```solidity
function P2() internal pure returns (G2Point memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`G2Point`|the generator of G2|


### negate


```solidity
function negate(G1Point memory p) internal pure returns (G1Point memory r);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`r`|`G1Point`|the negation of p, i.e. p.addition(p.negate()) should be zero.|


### addition


```solidity
function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`r`|`G1Point`|the sum of two points of G1|


### scalar_mul


```solidity
function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`r`|`G1Point`|the product of a point on G1 and a scalar, i.e. p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.|


### pairing


```solidity
function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|the result of computing the pairing check e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1 For example pairing([P1(), P1().negate()], [P2(), P2()]) should return true.|


### pairingProd2

Convenience method for a pairing check for two pairs.


```solidity
function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)
    internal
    view
    returns (bool);
```

### pairingProd3

Convenience method for a pairing check for three pairs.


```solidity
function pairingProd3(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2
) internal view returns (bool);
```

### pairingProd4

Convenience method for a pairing check for four pairs.


```solidity
function pairingProd4(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2,
    G1Point memory d1,
    G2Point memory d2
) internal view returns (bool);
```

## Structs
### G1Point

```solidity
struct G1Point {
    uint256 X;
    uint256 Y;
}
```

### G2Point

```solidity
struct G2Point {
    uint256[2] X;
    uint256[2] Y;
}
```

