import {BeaconChainAPI} from "../common/beacon-chain-api";
import {Utils} from "../common/utils";
import {SyncCommittee} from "../common/sync-committee";
import {bls, PublicKey} from "@chainsafe/bls/blst-native";
import {BitArray, fromHexString} from "@chainsafe/ssz";
import {ethers} from "ethers";
import minimist from "minimist";
import fs from "fs";

async function generateProofInput(slotStr: string) {
	console.log(`Generating Input data for proving that slot: ${slotStr}`);
	if (!(slotStr == 'latest' || !isNaN(Number(slotStr)))) {
		throw new Error('Slot is invalid. Must be `latest` or number');
	}
	const slot = Number(slotStr);
	const committee = await SyncCommittee.getValidatorsPubKey(slot);
	const beaconBlockHeader = await BeaconChainAPI.getBeaconBlockHeader(slot);
	// Sync Committee Bitmask and Signatures for slot X are at slot x+1
	const syncCommitteeAggregateData = await BeaconChainAPI.getSyncCommitteeAggregateData(slot + 1);
	const genesisValidatorRoot = await BeaconChainAPI.getGenesisValidatorRoot();
	const forkVersion = await BeaconChainAPI.getForkVersion(slot);
	const signingRoot = computeSigningRoot(forkVersion, genesisValidatorRoot, beaconBlockHeader);
	const syncCommitteeBits = SyncCommittee.getSyncCommitteeBits(syncCommitteeAggregateData.sync_committee_bits);

	await verifyBLSSignature(ethers.utils.arrayify(signingRoot), committee.pubKeys, syncCommitteeAggregateData.sync_committee_signature, syncCommitteeBits)
	const proofInput = {
		signing_root: Utils.hexToIntArray(signingRoot),
		pubkeys: committee.pubKeysInt,
		pubkeybits: syncCommitteeBits.map(e => { return e ? 1: 0}),
		signature: Utils.sigHexAsSnarkInput(syncCommitteeAggregateData.sync_committee_signature)
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

async function verifyBLSSignature(signingRoot: Uint8Array, pubKeys: PublicKey[], aggregateSyncCommitteeSignature: string, bitmap: boolean[]) {
	const bits = BitArray.fromBoolArray(bitmap);
	const activePubKeys = bits.intersectValues<PublicKey>(pubKeys);
	const aggPubkey = bls.PublicKey.aggregate(activePubKeys);
	const sig = bls.Signature.fromBytes(fromHexString(aggregateSyncCommitteeSignature), undefined, true);
	const success = sig.verify(aggPubkey, signingRoot);

	console.log("Successful BLS Signature verification: ", success);
}

function computeSigningRoot(forkVersion: string, genesisValidatorRoot: string, beaconBlock: any): string {
	const sszHeader = sszBeaconBlockHeader(beaconBlock);
	const domain = computeDomain(forkVersion, genesisValidatorRoot);
	return ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(sszHeader), domain]));
}

function sszBeaconBlockHeader(beaconBlock: any) {
	const left = ethers.utils.sha256(Buffer.concat([
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([Buffer.concat([toLittleEndian(Number(beaconBlock.slot))], 32), Buffer.concat([toLittleEndian(Number(beaconBlock.proposer_index))], 32)]))),
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(beaconBlock.parent_root), ethers.utils.arrayify(beaconBlock.state_root)])))
	]));
	const right = ethers.utils.sha256(Buffer.concat([
		ethers.utils.arrayify(ethers.utils.sha256(Buffer.concat([ethers.utils.arrayify(beaconBlock.body_root), ethers.utils.arrayify(ethers.constants.HashZero)]))),
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

// usage: yarn ts-node generate-proof-input.ts --slot=4278368
generateProofInput(slotArg);