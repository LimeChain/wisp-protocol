// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/crc-messages/CRCOutbox.sol";

import {SimpleLightClient} from "extractoor-contracts/L2/SimpleLightClient.sol";

contract MockLightClient is SimpleLightClient {
    constructor(address owner) SimpleLightClient(owner) {}
}

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        new MockLightClient(deployerAddress);

        vm.stopBroadcast();
    }
}

contract SetRootScript is Script {
    function run() external {
        address lightClientAddress = vm.envAddress("LIGHT_CLIENT");
        uint64 blockNumber = uint64(vm.envUint("BLOCK_NUMBER"));
        bytes32 _state = vm.envBytes32("STATE_ROOT");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        MockLightClient lightClient = MockLightClient(lightClientAddress);
        lightClient.setStateRoot(blockNumber, _state);

        vm.stopBroadcast();
    }
}

contract TransferOwnershipScript is Script {
    function run() external {
        address lightClientAddress = vm.envAddress("LIGHT_CLIENT");
        address newOwner = vm.envAddress("NEW_OWNER");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        MockLightClient lightClient = MockLightClient(lightClientAddress);
        lightClient.transferOwnership(newOwner);

        vm.stopBroadcast();
    }
}
