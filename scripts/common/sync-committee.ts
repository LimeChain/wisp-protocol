import {Utils} from "./utils";
import {PointG1} from "@noble/bls12-381";
import {BeaconChainAPI} from "./beacon-chain-api";

export namespace SyncCommittee {

	export async function getValidatorsPubKey(slot: number) {
		const committeePubKeys = await BeaconChainAPI.getSyncCommitteePubKeys(slot);

		const pubKeys = [];
		const pubKeysHex = [];
		for (let i = 0; i < committeePubKeys.length; i++) {
			const pubKey = committeePubKeys[i];
			const point = PointG1.fromHex(pubKey);
			const bigInts = Utils.pointToBigInt(point);
			pubKeys.push([
				Utils.bigIntToArray(bigInts[0]),
				Utils.bigIntToArray(bigInts[1])
			]);
			pubKeysHex.push(Utils.hexToIntArray(pubKey));
		}

		return {
			pubKeysString: committeePubKeys,
			pubKeysInt: pubKeys,
			pubKeysHex: pubKeysHex
		}
	}

	export function getSyncCommitteeBits(aggregatedBits: string) {
		let aggregatedBitsString: any[] = [];
		aggregatedBits = Utils.remove0x(aggregatedBits);
		for (let i = 0; i < aggregatedBits.length; i = i + 2) {
			let uint8Bits = parseInt(aggregatedBits[i] + aggregatedBits[i + 1], 16).toString(2);
			uint8Bits = padBitsToUint8Length(uint8Bits);
			aggregatedBitsString = aggregatedBitsString.concat(uint8Bits.split('').reverse());
		}
		return aggregatedBitsString.map(bit => Number(bit));
	}

	function padBitsToUint8Length(str: string): string {
		while (str.length < 8) {
			str = '0' + str;
		}
		return str;
	}
}