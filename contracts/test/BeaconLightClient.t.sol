pragma solidity 0.8.14;

import "forge-std/StdJson.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/lightclient/BeaconLightClient.sol";

contract BeaconLightClientTest is Test {
	using stdJson for string;

	BeaconLightClient lightClient;

	function setUp() public {
		(
		bytes32 genesisValidatorRoot,
		uint256 genesisTime,
		uint256 secondsPerSlot,
		bytes4 forkVersion,
		uint256 startSyncCommitteePeriod,
		bytes32 startSyncCommitteeRoot,
		bytes32 startSyncCommitteePoseidon
		) = readNetworkConfig("goerli");

		lightClient = new BeaconLightClient(
			genesisValidatorRoot,
			genesisTime,
			secondsPerSlot,
			forkVersion,
			startSyncCommitteePeriod,
			startSyncCommitteeRoot,
			startSyncCommitteePoseidon);
	}

	function testStep() external {
		LightClientUpdate memory lcUpdate = readLightClientUpdateTestData("goerli", "5009856");
		// TODO fix syncCommitteeRoot + Poseidon map
//		lightClient.step(lcUpdate);
	}

	function readNetworkConfig(string memory network) public view
	returns (bytes32 genesisValidatorRoot, uint256 genesisTime, uint256 secondsPerSlot, bytes4 forkVersion, uint256 period, bytes32 scRoot, bytes32 scpRoot){

		string memory root = vm.projectRoot();
		string memory path = string.concat(root, "/test/config/", network, ".json");
		string memory json = vm.readFile(path);

		genesisValidatorRoot = json.readBytes32(".genesisValidatorRoot");
		genesisTime = json.readUint(".genesisTime");
		secondsPerSlot = json.readUint(".secondsPerSlot");
		forkVersion = bytes4(json.parseRaw(".forkVersion"));
		period = json.readUint(".startSyncCommitteePeriod");
		scRoot = json.readBytes32(".startSyncCommitteeRoot");
		scpRoot = json.readBytes32(".startSyncCommitteePoseidon");
	}

	function readLightClientUpdateTestData(string memory network, string memory slot) public view returns (LightClientUpdate memory) {
		string memory root = vm.projectRoot();
		string memory path = string.concat(root, "/test/data/lightClientUpdate/", network, "/", slot, ".json");
		string memory json = vm.readFile(path);


		BeaconBlockHeader memory attestedHeader = BeaconBlockHeader(
			uint64(json.readUint(".attestedHeader.slot")),
			uint64(json.readUint(".attestedHeader.proposerIndex")),
			json.readBytes32(".attestedHeader.parentRoot"),
			json.readBytes32(".attestedHeader.stateRoot"),
			json.readBytes32(".attestedHeader.bodyRoot")
		);
		BeaconBlockHeader memory finalizedHeader = BeaconBlockHeader(
			uint64(json.readUint(".finalizedHeader.slot")),
			uint64(json.readUint(".finalizedHeader.proposerIndex")),
			json.readBytes32(".finalizedHeader.parentRoot"),
			json.readBytes32(".finalizedHeader.stateRoot"),
			json.readBytes32(".finalizedHeader.bodyRoot")
		);
		bytes32 executionStateRoot = json.readBytes32("executionStateRoot");
		bytes32[] memory executionStateRootBranch = json.readBytes32Array("executionStateRootBranch");
		bytes32 nextSyncCommitteeRoot = json.readBytes32("nextSyncCommitteeRoot");
		bytes32[] memory nextSyncCommitteeBranch = json.readBytes32Array("nextSyncCommitteeBranch");
		bytes32[] memory finalityBranch = json.readBytes32Array("finalityBranch");
		bytes memory updateBytes = json.parseRaw(".signature.proof");
		Groth16Proof memory proof = abi.decode(updateBytes, (Groth16Proof));
		uint64 participation = uint64(json.readUint(".signature.participation"));
		BLSAggregatedSignature memory signature = BLSAggregatedSignature(participation, proof);
		return LightClientUpdate(
			attestedHeader,
			finalizedHeader,
			finalityBranch,
			nextSyncCommitteeRoot,
			nextSyncCommitteeBranch,
			executionStateRoot,
			executionStateRootBranch,
			signature
		);
	}

	// todo readSSZ2PoseidonData
}
