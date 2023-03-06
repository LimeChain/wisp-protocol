// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types} from "./../libraries/Types.sol";

/// @notice Interface that the contracts receiving messages should implement
/// @author Perseverance
interface IMessageReceiver {
    /// @notice receives CRCMessageEnvelope
    /// @param envelope the message envelope you are receiving
    function receiveMessage(
        Types.CRCMessageEnvelope calldata envelope,
        uint256 sourceChainId
    ) external returns (bool success);
}
