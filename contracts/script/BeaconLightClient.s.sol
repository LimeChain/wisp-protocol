pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/lightclient/BeaconLightClient.sol";


contract DeployLightClient is Script {

	function run() external {
		uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
		vm.startBroadcast(deployerPrivateKey);

		bytes32 goerliGenesisValidatorRoot = bytes32(0x043db0d9a83813551ee2f33450d23797757d430911a9320530ad8a0eabc43efb);
		uint256 goerliGenesisType = 1616508000;
		uint256 goerliSecondsPerSlot = uint256(12);
		bytes4 goerliForkVersion = bytes4(0x02001020);

		// Important! The following script will deploy a Goerli Beacon Light Client starting from Period 620 (27 Feb 2023)
		uint256 goerliStartSyncCommitteePeriod = uint256(620);
		bytes32 goerliStartSyncCommitteeRoot = bytes32(0x454677fb351d04ceb9cc7ebfacfd3006f6f45ae3df14a602a7315f201b2bd022);
		bytes32 goerliStartSyncCommitteePoseidon = bytes32(uint256(1510457210206483705960711289730781220511670661511175082123243556470181199943));

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
