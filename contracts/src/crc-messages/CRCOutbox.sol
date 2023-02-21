// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ICRCOutbox} from "./interfaces/ICRCOutbox.sol";
import {Types} from "./libraries/Types.sol";

contract CRCOutbox is ICRCOutbox {
    /// @dev outbox for messages
    bytes32[] public outbox;

    /// @dev getting index by the message hash
    mapping(bytes32 => uint256) public indexOf;

    /// @dev used to nullify nonces
    mapping(address => mapping(uint64 => bool)) public noncesNullifier;

    event MessageSent(
        address indexed sender,
        uint256 indexed destinationChainId,
        bytes32 indexed hash,
        uint256 messageIndex
    );

    /// @notice sends CRC message. Stores it as keccak hash inside the outbox
    /// @dev Complete properties of a CRC message used for the hash are
    ///     uint8 - version
    ///     uint256 - destination chainId
    ///     uint64  - nonce to use against replay attacks
    ///     address - message sender
    ///     address - user - actual sender
    ///     address - target - the target contract in the destination chain
    ///     address - payload - the payload to be delivered to the target contract
    ///     address - stateRelayFee - the state relay fee
    ///     address - deliveryFee - the delivery fee
    ///     address - extra - extra bytes to be interpreted by dapps
    function sendMessage(Types.CRCMessage calldata message)
        public
        returns (bytes32 messageHash)
    {
        // TODO fees checks and takes
        require(
            !noncesNullifier[msg.sender][message.nonce],
            "Nonce already used"
        );

        uint256 messageIndex = outbox.length;

        noncesNullifier[msg.sender][message.nonce] = true;

        messageHash = keccak256(
            abi.encode(
                message.version,
                message.destinationChainId,
                message.nonce,
                msg.sender,
                message.user,
                message.target,
                message.payload,
                message.stateRelayFee,
                message.deliveryFee,
                message.extra
            )
        );

        outbox.push(messageHash);
        indexOf[messageHash] = messageIndex;

        emit MessageSent(
            msg.sender,
            message.destinationChainId,
            messageHash,
            messageIndex
        );

        return messageHash;
    }
}
