pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/lightclient/BeaconLightClient.sol";


contract DeployLightClient is Script {

	function run() external {
		uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
		vm.startBroadcast(deployerPrivateKey);

		// Important! The following script will deploy a Goerli Beacon Light Client starting from Period 614 (20 Feb 2023)
		bytes32 goerliGenesisValidatorRoot = bytes32(0x043db0d9a83813551ee2f33450d23797757d430911a9320530ad8a0eabc43efb);
		uint256 goerliGenesisType = 1616508000;
		uint256 goerliSecondsPerSlot = uint256(12);
		bytes4 goerliForkVersion = bytes4(0x02001020);
		uint256 goerliStartSyncCommitteePeriod = uint256(614);
		bytes32 goerliStartSyncCommitteeRoot = bytes32(0xf0f16518ff627161463f841297c7706ef553ba9ee543914e9bad705b3698e7ad);
		bytes32 goerliStartSyncCommitteePoseidon = bytes32(uint256(4766846997200404508116312410723043006238551660690027408290116075840455429660));

		BeaconLightClient lightClient = new BeaconLightClient(
			goerliGenesisValidatorRoot,
			goerliGenesisType,
			goerliSecondsPerSlot,
			goerliForkVersion,
			goerliStartSyncCommitteePeriod,
			goerliStartSyncCommitteeRoot,
			goerliStartSyncCommitteePoseidon);

		vm.stopBroadcast();
	}
}
