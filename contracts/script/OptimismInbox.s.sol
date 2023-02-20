// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/crc-messages/inbox/optimism/OptimismInbox.sol";

contract DeployScript is Script {
    function run() external {
        address _lightClient = vm.envAddress("LIGHT_CLIENT_ADDRESS");
        address _outputOracle = vm.envAddress("OUTPUT_ORACLE");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        OptimismInbox outbox = new OptimismInbox(_lightClient, _outputOracle);

        vm.stopBroadcast();
    }
}
