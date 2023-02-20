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
