// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types as CRCTypes} from "./libraries/Types.sol";

abstract contract CRCInbox {
    event InvokeSuccess(address indexed target, bytes32 indexed hash);
    event InvokeFailure(address indexed target, bytes32 indexed hash);

    event MessageReceived(
        address indexed user,
        address indexed target,
        bytes32 indexed hash
    );

    mapping(bytes32 => bool) public isUsed;
    mapping(bytes32 => address) public relayerOf;

    /// @notice generates the message hash of the given envelope
    /// @param envelope the message to get the hash of
    /// @return messageHash the message hash of this envelope
    function getMessageHash(CRCTypes.CRCMessageEnvelope calldata envelope)
        public
        pure
        returns (bytes32 messageHash)
    {
        // TODO add checks
        CRCTypes.CRCMessage memory message = envelope.message;

        return
            keccak256(
                abi.encode(
                    message.version,
                    message.destinationChainId,
                    message.nonce,
                    envelope.sender,
                    message.user,
                    message.target,
                    message.payload,
                    message.stateRelayFee,
                    message.deliveryFee,
                    message.extra
                )
            );
    }

    /// @notice gets the chainId for this contract network
    /// @return the chainId
    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /// @notice marks the message as relayed and stores the relayer
    /// @dev marks the msg.sender as the relayer
    /// @param messageHash the message hash to mark as relayed
    function markMessageRelayed(bytes32 messageHash) internal virtual {
        isUsed[messageHash] = true;
        relayerOf[messageHash] = msg.sender;
    }
}
