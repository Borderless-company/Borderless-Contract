// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless LETS Storage v0.1.0
 */
library Storage {
    bytes32 internal constant LETS_BASE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.LETSBase")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 internal constant LETS_SALE_BASE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.LETSSaleBase")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function LETSBaseSlot()
        internal
        pure
        returns (Schema.LETSBaseLayout storage $)
    {
        bytes32 slot = LETS_BASE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    function LETSSaleBaseSlot()
        internal
        pure
        returns (Schema.LETSSaleBaseLayout storage $)
    {
        bytes32 slot = LETS_SALE_BASE_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
