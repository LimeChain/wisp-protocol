// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types as CRCTypes} from "./../../libraries/Types.sol";
import {CRCInbox} from "./../../CRCInbox.sol";
import {L2OptimismBedrockStateProver} from "extractoor-contracts/L2/optimism/L2OptimismBedrockStateProver.sol";
import {Types as OptimismTypes} from "extractoor-contracts/library/optimism/Types.sol";

contract OptimismInbox is CRCInbox, L2OptimismBedrockStateProver {
    constructor(address _lightClient, address _oracleAddress)
        L2OptimismBedrockStateProver(_lightClient, _oracleAddress)
    {}

    function receiveMessage(
        CRCTypes.CRCMessageEnvelope calldata envelope,
        uint64 blockNumber,
        uint256 outputIndex,
        OptimismTypes.OutputRootMPTProof calldata outputProof,
        OptimismTypes.MPTInclusionProof calldata inclusionProof
    ) public virtual returns (bool success) {
        require(
            envelope.message.destinationChainId == getChainID(),
            "Message is not intended for this network"
        );

        bytes32 messageHash = getMessageHash(envelope);
        proveInOptimismState(
            blockNumber,
            outputIndex,
            outputProof,
            inclusionProof,
            uint256(messageHash)
        );

        // TODO Call target

        emit MessageReceived(
            envelope.sender,
            envelope.message.target,
            messageHash
        );
        return false;
    }
}
