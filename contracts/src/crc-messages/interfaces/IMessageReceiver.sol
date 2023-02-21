// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types} from "./../libraries/Types.sol";

interface IMessageReceiver {
    /// @notice receives CRCMessageEnvelope
    /// @param envelope the message envelope you are receiving
    function receiveMessage(Types.CRCMessageEnvelope calldata envelope)
        external
        returns (bool success);
}
