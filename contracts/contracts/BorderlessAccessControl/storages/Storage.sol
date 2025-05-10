// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title AccessControlUpgradeable Storage v0.1.0
 */
library Storage {
    bytes32 internal constant ACCESS_CONTROL_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("erc7201:openzeppelin:contracts.storage.BorderlessAccessControl")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    function AccessControlSlot() internal pure returns (Schema.AccessControlLayout storage $) {
        bytes32 slot = ACCESS_CONTROL_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
