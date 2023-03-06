// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types as CRCTypes} from "./libraries/Types.sol";
import {Owned} from "solmate/auth/Owned.sol";

/// @notice Abstract contract used as foundation for an inbox. Adds common functions and mappings.
/// @author Perseverance
abstract contract CRCInbox is Owned {
    event InvokeSuccess(address indexed target, bytes32 indexed hash);
    event InvokeFailure(address indexed target, bytes32 indexed hash);

    event MessageReceived(
        address indexed user,
        address indexed target,
        bytes32 indexed hash
    );

    /// @notice used for marking messages as used and protect against replay
    mapping(bytes32 => bool) public isUsed;

    /// @notice used for marking the relayer of a certain message
    mapping(bytes32 => address) public relayerOf;

    /// @notice Maps address of CRCOutbox in a certain source rollup or chain to its chainId
    mapping(address => uint256) public sourceChainIdFor;

    constructor() Owned(msg.sender) {}

    /// @notice Sets the chainid for CRCOutbox
    /// @param outbox the CRCOutbox contract address at the rollup
    /// @param chainId the chainId of the rollup
    function setChainIdFor(address outbox, uint256 chainId) public onlyOwner {
        // TODO in the future this should be improved as ideally outbox contracts have the same address on multiple networks
        sourceChainIdFor[outbox] = chainId;
    }

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
