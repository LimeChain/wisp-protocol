import {Utils} from "./utils";
import {PointG1} from "@noble/bls12-381";
import {BeaconChainAPI} from "./BeaconChainAPI";

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

}