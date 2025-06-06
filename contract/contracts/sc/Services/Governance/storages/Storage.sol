// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless Governance Storage v0.1.0
 */
library Storage {
    bytes32 internal constant GOVERNANCE_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("erc7201:borderless:contracts.storage.Governance")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    function GovernanceSlot() internal pure returns (Schema.GovernanceLayout storage $) {
        bytes32 slot = GOVERNANCE_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
