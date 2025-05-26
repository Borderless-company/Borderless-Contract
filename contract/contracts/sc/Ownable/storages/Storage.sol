// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title OpenZeppelin Ownable Storage v0.1.0
 */
library Storage {
    bytes32 internal constant OWNER_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.LETSBase")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function OwnableSlot()
        internal
        pure
        returns (Schema.OwnableLayout storage $)
    {
        bytes32 slot = OWNER_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
