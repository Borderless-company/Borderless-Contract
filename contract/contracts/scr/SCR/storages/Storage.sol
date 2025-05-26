// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless SCR Storage v0.1.0
 */
library Storage {
    bytes32 internal constant SCR_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("erc7201:borderless:contracts.storage.SCR")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    function SCRSlot() internal pure returns (Schema.SCRLayout storage $) {
        bytes32 slot = SCR_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
