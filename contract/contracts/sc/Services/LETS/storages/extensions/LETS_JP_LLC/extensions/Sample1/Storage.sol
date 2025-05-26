// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless LETS Storage v0.1.0
 */
library Storage {
    bytes32 internal constant SAMPLE1_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.LETS_JP_LLC_EXE_Sample1")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function Sample1Slot()
        internal
        pure
        returns (Schema.Sample1Layout storage $)
    {
        bytes32 slot = SAMPLE1_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
