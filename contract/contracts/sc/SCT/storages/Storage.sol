// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless SCR Storage v0.1.0
 */
library Storage {
    bytes32 internal constant SCT_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("erc7201:borderless:contracts.storage.SCT")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    function SCTSlot() internal pure returns (Schema.SCTLayout storage $) {
        bytes32 slot = SCT_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
