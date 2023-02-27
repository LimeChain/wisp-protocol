// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/crc-messages/CRCInbox.sol";

contract SetCRCInboxRegistry is Script {
    function run() external {
        address inboxAddress = vm.envAddress("CRC_INBOX");
        address outbox = vm.envAddress("OUTBOX_ADDRESS");
        uint256 chainId = vm.envUint("CHAIN_ID");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CRCInbox inbox = CRCInbox(inboxAddress);

        inbox.setChainIdFor(outbox, chainId);

        vm.stopBroadcast();
    }
}
