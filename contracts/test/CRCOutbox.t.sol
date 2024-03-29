// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./../src/crc-messages/CRCOutbox.sol";
import "./../src/crc-messages/libraries/Types.sol";

contract CRCOutboxTest is Test {
    event MessageSent(
        address indexed sender,
        uint256 indexed destinationChainId,
        bytes32 indexed hash,
        uint256 messageIndex
    );

    CRCOutbox public outbox;

    function setUp() public {
        outbox = new CRCOutbox();
    }

    function testSendMessage(
        uint8 version,
        uint256 destinationChainId,
        uint64 nonce,
        address user,
        address target,
        bytes calldata payload,
        uint256 stateRelayFee,
        uint256 deliveryFee,
        bytes calldata extra
    ) public {
        Types.CRCMessage memory message = Types.CRCMessage({
            version: version,
            destinationChainId: destinationChainId,
            nonce: nonce,
            user: user,
            target: target,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });

        bytes32 messageHash = keccak256(
            abi.encode(
                message.version,
                message.destinationChainId,
                message.nonce,
                address(this),
                message.user,
                message.target,
                message.payload,
                message.stateRelayFee,
                message.deliveryFee,
                message.extra
            )
        );

        vm.expectEmit(true, true, true, true);

        emit MessageSent(
            address(this),
            message.destinationChainId,
            messageHash,
            0
        );
        outbox.sendMessage(message);

        assertEq(outbox.outbox(0), messageHash);
        assertEq(outbox.indexOf(messageHash), 0);
        assertEq(outbox.noncesNullifier(address(this), nonce), true);

        Types.CRCMessage memory savedMessage = outbox.getMessageByIndex(0);

        bytes32 messageHashFromSaved = keccak256(
            abi.encode(
                savedMessage.version,
                savedMessage.destinationChainId,
                savedMessage.nonce,
                address(this),
                savedMessage.user,
                savedMessage.target,
                savedMessage.payload,
                savedMessage.stateRelayFee,
                savedMessage.deliveryFee,
                savedMessage.extra
            )
        );

        assertEq(messageHashFromSaved, messageHash);
    }

    function testRevertingReplay(
        uint8 version,
        uint256 destinationChainId,
        uint64 nonce,
        address user,
        address target,
        bytes calldata payload,
        uint256 stateRelayFee,
        uint256 deliveryFee,
        bytes calldata extra
    ) public {
        Types.CRCMessage memory message = Types.CRCMessage({
            version: version,
            destinationChainId: destinationChainId,
            nonce: nonce,
            user: user,
            target: target,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });

        outbox.sendMessage(message);

        vm.expectRevert("Nonce already used");
        outbox.sendMessage(message);
    }
}
