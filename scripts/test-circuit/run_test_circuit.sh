#!/bin/bash

set -e

BUILD_DIR=../../circuits/temp/build
COMPILED_DIR=$BUILD_DIR/compiled_circuit
TRUSTED_SETUP_DIR=$BUILD_DIR/trusted_setup

#SYNC_COMMITTEE_PROOF=../circuits/temp/proof_data_${SYNC_COMMITTEE_PERIOD}
CIRCUIT_NAME=Multiplier2
CIRCUIT_PATH=../../circuits/temp/$CIRCUIT_NAME.circom

run () {
#  echo "SYNC_COMMITTEE_PERIOD: $SYNC_COMMITTEE_PERIOD"

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

#  if [ ! -f "$COMPILED_DIR"/"$CIRCUIT_NAME".r1cs ]; then
      echo "**** COMPILING CIRCUIT $CIRCUIT_NAME.circom ****"
      start=`date +%s`
      circom "$CIRCUIT_PATH" --O1 --r1cs --sym --c --output "$COMPILED_DIR"
      end=`date +%s`
      echo "DONE ($((end-start))s)"
#  fi

#  if [ ! -d "$SYNC_COMMITTEE_PROOF" ]; then
#      echo "No directory found for proof data. Creating a sync committee's proof data directory..."
#      mkdir "$SYNC_COMMITTEE_PROOF"
#  fi

#  echo "====GENERATING INPUT FOR PROOF===="
#  echo $SYNC_COMMITTEE_PROOF/input.json
#  start=`date +%s`
#  yarn ts-node --project tsconfig.json generateProofInput.ts --period ${SYNC_COMMITTEE_PERIOD}
#  end=`date +%s`
#  echo "DONE ($((end-start))s)"


}

mkdir -p logs
run 2>&1 | tee logs/"$CIRCUIT_NAME"_$(date '+%Y-%m-%d-%H-%M').log