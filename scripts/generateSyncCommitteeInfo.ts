// @ts-ignore
import minimist from "minimist";
import axios from 'axios';

const BEACON_API_PATH = 'https://beaconcha.in/api/v1/sync_committee/';

async function generateSyncCommitteeInfo(period: string) {
	console.log(`Fetching Sync Committee for period: ${period}`)

	if (!(period == 'latest' || period == 'next' || !isNaN(Number(period)))) {
		throw new Error('Period is invalid. Must be `latest`, `next` or number');
	}

	const result = await axios.get(BEACON_API_PATH + period);
	const committee = result.data.data.validators;
	// TODO write the committee in a file
}

const argv = minimist(process.argv.slice(1));
const committeePeriod = argv.period || process.env.COMMITTEE_PERIOD;

if (!committeePeriod) {
	throw new Error("CLI arg 'committee_period' is required!")
}

// usage: yarn ts-node generateSyncCommitteeInfo.ts --period=495
generateSyncCommitteeInfo(committeePeriod)