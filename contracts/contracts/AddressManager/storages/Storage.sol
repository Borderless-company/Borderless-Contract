// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless Storage v0.1.0
 */
library Storage {
    bytes32 public constant ADDRESS_MANAGER_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.addressManager")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function AddressManagerSlot()
        internal
        pure
        returns (Schema.AddressManagerLayout storage $)
    {
        bytes32 slot = ADDRESS_MANAGER_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
