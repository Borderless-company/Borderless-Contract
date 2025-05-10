// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Initialize Storage v0.1.0
 */
library Storage {
    bytes32 internal constant INITIALIZE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:borderless:contracts.storage.Initialize"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function InitializeSlot()
        internal
        pure
        returns (Schema.InitializeLayout storage $)
    {
        bytes32 slot = INITIALIZE_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
