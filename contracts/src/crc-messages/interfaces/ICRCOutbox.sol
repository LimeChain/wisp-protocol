// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types} from "./../libraries/Types.sol";

/// @notice Interface for external contracts to work with the outbox
/// @author Perseverance
interface ICRCOutbox {
    event MessageSent(
        address indexed sender,
        uint256 indexed destinationChainId,
        bytes32 indexed hash,
        uint256 messageIndex
    );

    /// @notice getter for message hashes based on their index
    /// @param outboxIndex the index in the outbox of the message whose hash will be returned
    /// @return messageHash the hash of the message for this outboxIndex
    function outbox(uint256 outboxIndex)
        external
        view
        returns (bytes32 messageHash);

    /// @notice getter for message index based on their hash
    /// @param messageHash the message hash to get the index of
    /// @return outboxIndex the index in the outbox of this message hash
    function indexOf(bytes32 messageHash)
        external
        view
        returns (uint256 outboxIndex);

    /// @notice used to check if a nullifier has been used for the specified account
    /// @param sender the sender of message
    /// @param nonce the nullifier for this message
    /// @return used if the nullifier has been used
    function noncesNullifier(address sender, uint64 nonce)
        external
        view
        returns (bool used);

    /// @notice sends CRCMessage
    /// @param message the message to be sent
    /// @return messageHash the hash of the message that was sent
    function sendMessage(Types.CRCMessage calldata message)
        external
        returns (bytes32 messageHash);

    /// @notice gets CRC Message by its index
    /// @param index the index of the message in the outbox
    /// @return message the raw CRC Message
    function getMessageByIndex(uint256 index)
        external
        view
        returns (Types.CRCMessage memory message);
}
