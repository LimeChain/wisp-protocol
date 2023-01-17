#!/bin/bash

# TODO
# High level steps:
# 1. Gets the current Sync Committee of Ethereum
# 2. Generates input for the circuit - BLS12-381 single and aggregated public keys (in hex and BigInt) and size
# 3. Compiles the circuit
# 4. Generates a witness
# 5. Generates a trusted setup.
# 6. Generates a proof.
# 7. Generates TX calldata for the verifier contract (`updateSyncCommittee`)