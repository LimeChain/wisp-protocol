# CRC Protocol

[![Tests](https://github.com/LimeChain/crc-protocol/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/LimeChain/crc-protocol/actions/workflows/ci.yml)

## Overview

Messaging Protocol for transfer of data between Rollups based on Computational Integrity (SNARK/STARKs) proving the
state of Ethereum (acting as an on-chain Light Client) inside the Destination rollup.

For the PoC version of CRC, the circuits and the on-chain Light Client are based
on [SuccinctLabs Proof-of-Consensus](https://github.com/succinctlabs/eth-proof-of-consensus) implementation.

## Getting Started

**Note: It is recommended to use Ubuntu 22.04**

To get started with this repo, you will need to have the following set up on your machine:

- [Foundry](https://github.com/foundry-rs/foundry) to compile contracts and run Solidity tests
- [NPM](https://www.npmjs.com/) and [Node.js](https://nodejs.org/)
- [Circom](https://docs.circom.io/getting-started/installation/) in order to interact with the circuits

## Directory Structure

The project is structured as a mixed Solidity, Circom, and TypeScript workspace.

```
├── circuits  // <-- Circom code
├── contracts // <-- Solidity code
├── scripts   // <-- Sync Committee commitment, Aggregate BLS verifcation & proof generation utils
```

## Setup

### Circuits

```bash
cd ./circuits && npm i
```

### Contracts

```bash
cd ./contracts && forge install && forge build
```

In order to run the tests for the contracts execute `forge test`

### Scripts

The `./scripts` folder contains a npm project supporting 2 scripts

- `syncCommitteeComittment` prepares the circuits and the trusted setup if necessary. Generates a proof of mapping the
  SSZ merkelized Sync Committee root to a Poseidon merkelized root by providing it with committee period as input.
- `verifyHeaderSignatures` prepares the circuits and the trusted setup if necessary. Generates a proof that at least 2/3
  of the sync committee has signed the specified block header. The script takes as argument only the slot for which a
  proof must be generated.

**Prerequisites**

1. The following tools must be installed in order for you to successfully execute the bash scripts:
    1. Build [RapidSnark](https://github.com/iden3/rapidsnark) and put `prover` binary at `./scripts/build`
    2. g++
    3. nlohmann-json3-dev
    4. libmpc-dev
    5. nasm
2. The following script must be executed in order for you to generate a zkey:
    1. Update the current `max_map_count` of the system by executing: `sysctl -w vm.max_map_count=655300`
    2. Add `vm.max_map_count=655300` in `/etc/sysctl.conf` in order to persist the change
3. Download the [PowersOfTau27](https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_27.ptau) file
   from [SnarkJS](https://github.com/iden3/snarkjs#7-prepare-phase-2) and place it
   at `./circuits/powers_of_tau/powersOfTau28_hez_final_27.ptau`

**Sync Committee Proof**

```bash
cd ./scripts && npm i
cd ./syncCommitteeComittment && SYNC_COMMITTEE_PERIOD={INPUT} bash run_sync_committee_commitment.sh &
```

**Verify Header Signatures**

```bash
cd ./scripts && npm i
cd ./verifyHeaderSignatures && SLOT={INPUT} bash run_verify_header_signatures.sh &
```

Start the processes in the background since it might take a while depending on whether you've compiled / generated the
zkey. A `logs` folder for the execution will be created.