# Wisp Protocol

[![Tests](https://github.com/LimeChain/wisp-protocol/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/LimeChain/crc-protocol/actions/workflows/ci.yml)

## Overview

Messaging Protocol for transfer of data between Rollups based on Computational Integrity (SNARK) proving the
state of Ethereum (acting as an on-chain Light Client) inside the Destination rollup.

For the PoC version of Wisp, the circuits and the on-chain Light Client are based
on [SuccinctLabs Proof-of-Consensus](https://github.com/succinctlabs/eth-proof-of-consensus) implementation.

## Directory Structure

The project is structured as a mixed Solidity, Circom, and TypeScript workspace.

```
├── circuits  // <-- Circom code
├── contracts // <-- Solidity code
├── scripts   // <-- Sync Committee commitment, Aggregate BLS verifcation & Proof generation utils
```

More information for each of them:
- [Circuits](./circuits/README.md)
- [Contracts](./contracts/README.md)
- [Scripts](./scripts/README.md)

## License

TODO
