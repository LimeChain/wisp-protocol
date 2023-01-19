#!/bin/bash

# High level steps:
# 1. Gets the current Sync Committee of Ethereum
# 2. Generates input for the circuit - BLS12-381 single and aggregated public keys (in hex and BigInt) and size
# 3. Compiles the circuit
# 4. Generates a witness
# 5. Generates a trusted setup.
# 6. Generates a proof.
# 7. Generates TX calldata for the verifier contract (`updateSyncCommittee`)

set -e

# Download the powers of tau file from here: https://github.com/iden3/snarkjs#7-prepare-phase-2
# Move to directory specified below

BUILD_DIR=../../circuits/verify_ssz_to_poseidon_commitment/build
COMPILED_DIR=$BUILD_DIR/compiled_circuit
TRUSTED_SETUP_DIR=$BUILD_DIR/trusted_setup

SYNC_COMMITTEE_PROOF=../../circuits/verify_ssz_to_poseidon_commitment/proof_data_${SYNC_COMMITTEE_PERIOD}
CIRCUIT_NAME=test_sync_committee_committments
CIRCUIT_PATH=../../circuits/verify_ssz_to_poseidon_commitment/$CIRCUIT_NAME.circom

run () {
  echo "SYNC_COMMITTEE_PERIOD: $SYNC_COMMITTEE_PERIOD"

  if [ ! -d "$BUILD_DIR" ]; then
      echo "No build directory found. Creating build directory..."
      mkdir "$BUILD_DIR"
  fi

  if [ ! -d "$COMPILED_DIR" ]; then
      echo "No compiled directory found. Creating compiled circuit directory..."
      mkdir "$COMPILED_DIR"
  fi

  if [ ! -d "$TRUSTED_SETUP_DIR" ]; then
      echo "No trusted setup directory found. Creating trusted setup directory..."
      mkdir "$TRUSTED_SETUP_DIR"
  fi

  if [ ! -d "$SYNC_COMMITTEE_PROOF" ]; then
      echo "No directory found for proof data. Creating a sync committee's proof data directory..."
      mkdir "$SYNC_COMMITTEE_PROOF"
  fi

  echo "====GENERATING INPUT FOR PROOF===="
  echo $SYNC_COMMITTEE_PROOF/input.json
  start=`date +%s`
  yarn ts-node --project tsconfig.json ./ssz_sync_committee/generateProofInput.ts --period ${SYNC_COMMITTEE_PERIOD}
  end=`date +%s`
  echo "DONE ($((end-start))s)"

#  if [ ! -f "$COMPILED_DIR"/"$CIRCUIT_NAME".r1cs ]; then
#      echo "**** COMPILING CIRCUIT $CIRCUIT_NAME.circom ****"
#      start=`date +%s`
#      circom "$CIRCUIT_PATH" --O1 --r1cs --sym --c --output "$COMPILED_DIR"
#      end=`date +%s`
#      echo "DONE ($((end-start))s)"
#  fi


}

mkdir -p logs
run 2>&1 | tee logs/"$CIRCUIT_NAME"_$(date '+%Y-%m-%d-%H-%M').log