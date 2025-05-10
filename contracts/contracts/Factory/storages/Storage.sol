// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless Service Factory Storage v0.1.0
 */
library Storage {
    bytes32 internal constant SERVICE_FACTORY_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:borderless:contracts.storage.ServiceFactory"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function ServiceFactorySlot()
        internal
        pure
        returns (Schema.ServiceFactoryLayout storage $)
    {
        bytes32 slot = SERVICE_FACTORY_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
