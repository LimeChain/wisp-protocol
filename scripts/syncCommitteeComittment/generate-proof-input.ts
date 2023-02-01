const minimist = require("minimist");
const fs = require('fs');
import {aggregatePublicKeys} from "@noble/bls12-381";
import {SyncCommittee} from "../common/sync-committee";

const SLOTS_PER_SYNC_COMMITTEE_PERIOD = 8192

async function generateProofInput(period: string) {
	console.log(`Generating Input data for proving Sync Committee for period: ${period}`)

	if (!(period == 'latest' || period == 'next' || !isNaN(Number(period)))) {
		throw new Error('Period is invalid. Must be `latest`, `next` or number');
	}

	const slot = Number(period) * SLOTS_PER_SYNC_COMMITTEE_PERIOD;
	const result = await SyncCommittee.getValidatorsPubKey(slot);
	const aggregatePubKeyBytes = aggregatePublicKeys(result.pubKeysString);
	const aggregatePubKeyHex: string[] = [];
	aggregatePubKeyBytes.forEach(v => aggregatePubKeyHex.push(v.toString()));
	const proofInput = {
		pubkeys: result.pubKeysInt,
		pubkeyHex: result.pubKeysHex,
		aggregatePubkeyHex: aggregatePubKeyHex
	}

	// Write object to a block specific folder in circuits directory.
	const dir = `../circuits/verify_ssz_to_poseidon_commitment/proof_data_${period}`;
	if (!fs.existsSync(dir)) {
		fs.mkdirSync(dir);
	}
	const file = `../circuits/verify_ssz_to_poseidon_commitment/proof_data_${period}/input.json`;
	fs.writeFileSync(
		file,
		JSON.stringify(proofInput)
	);

	console.log("Finished writing proof input file", file);
}

const argv = minimist(process.argv.slice(1));
const committeePeriod = argv.period || process.env.COMMITTEE_PERIOD;

if (!committeePeriod) {
	throw new Error("CLI arg 'committee_period' is required!")
}

// usage: yarn ts-node generate-proof-input.ts --period=495
generateProofInput(committeePeriod)