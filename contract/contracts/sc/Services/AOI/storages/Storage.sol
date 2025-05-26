// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless AOI Storage v0.1.0
 */
library Storage {
    bytes32 internal constant AOI_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("erc7201:borderless:contracts.storage.AOI")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    function AOISlot() internal pure returns (Schema.AOILayout storage $) {
        bytes32 slot = AOI_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
