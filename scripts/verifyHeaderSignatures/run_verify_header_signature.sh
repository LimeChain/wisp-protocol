#!/bin/bash

# High level steps:
# 1. TODO
# 2. TODO
# 3. Compiles the circuit (if not compiled)
# 4. Generates a witness
# 5. Generates a trusted setup (if not generated)
# 6. Generates a proof
# 7. Generates TX calldata for the verifier contract (`step`)

set -e

# Download the powers of tau file from here: https://github.com/iden3/snarkjs#7-prepare-phase-2
# Move to directory specified below
PHASE1=../../circuits/powers_of_tau/powersOfTau28_hez_final_27.ptau

BASE_CIRCUIT_DIR=../../circuits/verify_header_signatures
BUILD_DIR=$BASE_CIRCUIT_DIR/build
COMPILED_DIR=$BUILD_DIR/compiled_circuit
TRUSTED_SETUP_DIR=$BUILD_DIR/trusted_setup

SLOT_PROOF=$BASE_CIRCUIT_DIR/proof_data_${SLOT}
CIRCUIT_NAME=test_assert_valid_signed_header
CIRCUIT_PATH=../../circuits/verify_header_signatures/$CIRCUIT_NAME.circom
OUTPUT_DIR=$COMPILED_DIR/$CIRCUIT_NAME_cpp

run() {
  echo "SLOT: $SLOT"

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

  if [ ! -d "$SLOT_PROOF" ]; then
    echo "No directory found for proof data. Creating a slot's proof data directory..."
    mkdir "$SLOT_PROOF"
  fi

  echo "====GENERATING INPUT FOR PROOF===="
  echo $SLOT_PROOF/input.json
  start=$(date +%s)
  yarn ts-node --project tsconfig.json ./verifyHeaderSignatures/generateProofInput.ts --slot $SLOT
  end=$(date +%s)
  echo "DONE ($((end - start))s)"

}

mkdir -p logs
run 2>&1 | tee logs/"$CIRCUIT_NAME"_$(date '+%Y-%m-%d-%H-%M').log
