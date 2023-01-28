import {BeaconChainAPI} from "../common/BeaconChainAPI";
import {Utils} from "../common/utils";
import {SyncCommittee} from "../common/SyncCommittee";

const {ethers} = require('ethers');
const minimist = require("minimist");
const fs = require("fs");

async function generateProofInput(slotStr: string) {
	console.log(`Generating Input data for proving that slot: ${slotStr}`);
	if (!(slotStr == 'latest' || !isNaN(Number(slotStr)))) {
		throw new Error('Slot is invalid. Must be `latest` or number');
	}
	const slot = Number(slotStr);
	// Compute the representative period for the slot
	const result = await SyncCommittee.getValidatorsPubKey(slot);
	const beaconBlockHeader = await BeaconChainAPI.getBeaconBlockHeader(slot);
	const genesisValidatorRoot = await BeaconChainAPI.getGenesisValidatorRoot();
	const forkVersion = await BeaconChainAPI.getForkVersion(slot);
	const signingRoot = computeSigningRoot(forkVersion, genesisValidatorRoot, beaconBlockHeader);
	const proofInput = {
		signing_root: signingRoot,
		pubkeys: result.pubKeysInt,
		pubkeybits: [],
		signature: []
	}

	// Write object to a block specific folder in circuits directory.
	const dir = `../circuits/verify_header_signatures/proof_data_${slot}`;
	if (!fs.existsSync(dir)) {
		fs.mkdirSync(dir);
	}
	const file = `../circuits/verify_header_signatures/proof_data_${slot}/input.json`;
	fs.writeFileSync(
		file,
		JSON.stringify(proofInput)
	);
	console.log("Finished writing proof input file", file);
}

function computeSigningRoot(forkVersion: string, genesisValidatorRoot: string, beaconBlockHeader: any): string[] {
	const sszHeader = sszBeaconBlockHeader(beaconBlockHeader);
	const domain = computeDomain(forkVersion, genesisValidatorRoot);
	return Utils.hexToIntArray(
		ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(sszHeader), domain]))
	);
}

function sszBeaconBlockHeader(header: any) {
	const left = ethers.utils.sha256(Buffer.concat([
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([Buffer.concat([toLittleEndian(Number(header.slot))], 32), Buffer.concat([toLittleEndian(Number(header.proposer_index))], 32)]))),
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(header.parent_root), ethers.utils.arrayify(header.state_root)])))
	]));
	const right = ethers.utils.sha256(Buffer.concat([
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(header.body_root), ethers.utils.arrayify(ethers.constants.HashZero)]))),
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(ethers.constants.HashZero), ethers.utils.arrayify(ethers.constants.HashZero)])))
	]));
	return ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(left), ethers.utils.arrayify(right)]));
}

function toLittleEndian(number: number): Buffer {
	let buf = Buffer.alloc(32)
	buf.writeUInt32LE(number);
	return buf;
}

function computeDomain(forkVersionStr: string, genesisValidatorsRootStr: string): Uint8Array {
	const forkVersion = ethers.utils.arrayify(forkVersionStr);
	const genesisValidatorRoot = ethers.utils.arrayify(genesisValidatorsRootStr);
	const right = ethers.utils.arrayify(ethers.utils.sha256(ethers.utils.defaultAbiCoder.encode(["bytes4", "bytes32"], [forkVersion, genesisValidatorRoot])));
	// SYNC_COMMITTEE_DOMAIN_TYPE https://github.com/ethereum/consensus-specs/blob/da3f5af919be4abb5a6db5a80b235deb8b4b5cba/specs/altair/beacon-chain.md#domain-types
	const domain = new Uint8Array(32);
	domain.set([7, 0, 0, 0], 0);
	domain.set(right.slice(0, 28), 4);
	return domain;
}

const argv = minimist(process.argv.slice(1));
const slotArg = argv.slot || process.env.SLOT;

if (!slotArg) {
	throw new Error("CLI arg 'slot' is required!")
}

// usage: yarn ts-node generateProofInput.ts --slot=4278368
generateProofInput(slotArg);