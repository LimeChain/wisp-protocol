#!/bin/bash

echo "****COMPILING CIRCUIT****"
start=`date +%s`
circom test_sync_committee_committments.circom --O1 --r1cs --sym --c --output result
end=`date +%s`
echo "DONE ($((end-start))s)"

