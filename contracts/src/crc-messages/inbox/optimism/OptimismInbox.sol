// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types as CRCTypes} from "./../../libraries/Types.sol";
import {CRCInbox} from "./../../CRCInbox.sol";
import {L2OptimismBedrockStateProver} from "extractoor-contracts/L2/optimism/L2OptimismBedrockStateProver.sol";
import {Types as OptimismTypes} from "extractoor-contracts/library/optimism/Types.sol";
import {IMessageReceiver} from "./../../interfaces/IMessageReceiver.sol";

contract OptimismInbox is CRCInbox, L2OptimismBedrockStateProver {
    constructor(address _lightClient, address _oracleAddress)
        L2OptimismBedrockStateProver(_lightClient, _oracleAddress)
    {}

    /// @notice Method to trigger the receiving of a CRC message
    /// @dev calls the target contract with the message but does not revert even if the target call reverts.
    /// @param envelope The envelope of the message that is being relayed
    /// @param blockNumber The block number to request the L1 state root for
    /// @param outputIndex The index to find the output proof at inside the Bedrock OutputOracle
    /// @param outputProof The MPT proof data to verify that the given Optimism output root is contained inside the OutputOracle for the expected index
    /// @param inclusionProof The MPT proof data to verify that the given data is contained at a given slot inside Optimism
    /// @return success if the output root is indeed there
    function receiveMessage(
        CRCTypes.CRCMessageEnvelope calldata envelope,
        uint64 blockNumber,
        uint256 outputIndex,
        OptimismTypes.OutputRootMPTProof calldata outputProof,
        OptimismTypes.MPTInclusionProof calldata inclusionProof
    ) public virtual returns (bool success) {
        assert(envelope.message.target != address(this));
        require(
            envelope.message.destinationChainId == getChainID(),
            "Message is not intended for this network"
        );

        uint256 sourceChainId = sourceChainIdFor[inclusionProof.target];

        require(sourceChainId > 0, "Unrecognized CRCOutbox contract");

        bytes32 messageHash = getMessageHash(envelope);

        require(!isUsed[messageHash], "Message already received");
        markMessageRelayed(messageHash);

        proveInOptimismState(
            blockNumber,
            outputIndex,
            outputProof,
            inclusionProof,
            uint256(messageHash)
        );

        (bool callSuccess, bytes memory data) = envelope.message.target.call(
            abi.encodeWithSelector(
                IMessageReceiver.receiveMessage.selector,
                envelope,
                sourceChainId
            )
        );

        bool receiveSuccess = false;
        if (data.length > 0) {
            (receiveSuccess) = abi.decode(data, (bool));
        }

        if (callSuccess && receiveSuccess) {
            emit InvokeSuccess(envelope.message.target, messageHash);
        } else {
            emit InvokeFailure(envelope.message.target, messageHash);
        }

        emit MessageReceived(
            envelope.sender,
            envelope.message.target,
            messageHash
        );
        return true;
    }
}
