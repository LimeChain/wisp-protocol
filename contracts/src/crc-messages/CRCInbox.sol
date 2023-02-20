// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types as CRCTypes} from "./libraries/Types.sol";

abstract contract CRCInbox {
    event MessageReceived(
        address indexed user,
        address indexed target,
        bytes32 indexed hash
    );

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

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}
