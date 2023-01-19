import minimist from "minimist";
import fs from 'fs';
import axios from 'axios';
import {aggregatePublicKeys, PointG1} from "@noble/bls12-381";
import {Utils} from "../utils/utils";

const BEACON_API_BASE = 'https://beaconcha.in/api/v1';
const BEACON_API_SYNC_COMMITTEE_API = `${BEACON_API_BASE}/sync_committee/`;
const BEACON_API_VALIDATOR_INFO_API = `${BEACON_API_BASE}/validator/`;
const PUB_KEY_BATCH_SIZE = 100;

const N: number = 55; // The number of bits to use per register
const K: number = 7; // The number of registers

async function generateProofInput(period: string) {
	console.log(`Fetching Sync Committee for period: ${period}`)

	if (!(period == 'latest' || period == 'next' || !isNaN(Number(period)))) {
		throw new Error('Period is invalid. Must be `latest`, `next` or number');
	}

	const result = await axios.get(BEACON_API_SYNC_COMMITTEE_API + period);
	const committee = result.data.data.validators;

	const committeePubKeys = [];
	for (let i = 0; i < Math.ceil(committee.length / PUB_KEY_BATCH_SIZE); i++) {
		const validatorIndices = committee.slice(i * PUB_KEY_BATCH_SIZE, (i + 1) * PUB_KEY_BATCH_SIZE);
		const resp = await axios.get(BEACON_API_VALIDATOR_INFO_API + validatorIndices.toString());
		const validatorsBatchInfo = resp.data.data;
		for (let index in validatorsBatchInfo) {
			committeePubKeys.push(Utils.remove0x(validatorsBatchInfo[index]['pubkey']));
		}
	}

	const pubKeys = [];
	const pubKeysHex = [];
	for (let i = 0; i < committeePubKeys.length; i++) {
		const pubKey = committeePubKeys[i];
		const point = PointG1.fromHex(pubKey);
		const bigInts = Utils.pointToBigInt(point);
		pubKeys.push([
			Utils.bigIntToArray(N, K, bigInts[0]),
			Utils.bigIntToArray(N, K, bigInts[1])
		]);
		pubKeysHex.push(Utils.hexToIntArray(pubKey));
	}
	const aggregatePubKeyBytes = aggregatePublicKeys(committeePubKeys);
	const aggregatePubKeyHex: string[] = [];
	aggregatePubKeyBytes.forEach(v => aggregatePubKeyHex.push(v.toString()));
	const proofInput = {
		pubkeys: pubKeys,
		pubkeyHex: pubKeysHex,
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

// usage: yarn ts-node generateProofInput.ts --period=495
generateProofInput(committeePeriod)