# CRC Protocol

[![Tests](https://github.com/LimeChain/crc-protocol/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/LimeChain/crc-protocol/actions/workflows/ci.yml)

## Overview

Messaging Protocol for transfer of data between Rollups based on Computational Integrity (SNARK/STARKs) proving the
state of Ethereum (acting as an on-chain Light Client) inside the Destination rollup.

For the PoC version of CRC, the circuits and the on-chain Light Client are based
on [SuccinctLabs Proof-of-Consensus](https://github.com/succinctlabs/eth-proof-of-consensus) implementation.

## Getting Started

To get started with this repo, you will need to have the following set up on your machine:

- [Foundry](https://github.com/foundry-rs/foundry) to compile contracts and run Solidity tests
- [Yarn](https://yarnpkg.com/) and [Node.js](https://nodejs.org/)
- [Circom](https://docs.circom.io/getting-started/installation/) in order to interact with the circuits

### Directory Structure

The project is structured as a mixed Solidity, Circom, and Typescript workspace.

```
├── circuits  // <-- Circom code
├── contracts // <-- Solidity code
├── scripts   // <-- Sync Committee commitment, Aggregate BLS verifcation & proof generation utils
```

### Setup

TODO

0. `cd ./contracts`
1. `forge install`
2. `forge build`
3. `forge test`

## Ethereum Light Client

TODO:

- move different ZKPs to different folders within `circuits`
- add top-level `./scripts` folder that has TS code to fetch input data and triggers the compilation of the circuits for
  a specific slot providing the input data along with it
