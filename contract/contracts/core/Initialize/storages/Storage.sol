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

    bytes32 internal constant AOI_INITIALIZE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.AOIInitialize")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function AOIInitializeSlot()
        internal
        pure
        returns (Schema.InitializeLayout storage $)
    {
        bytes32 slot = AOI_INITIALIZE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    bytes32 internal constant SCT_INITIALIZE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.SCTInitialize")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function SCTInitializeSlot()
        internal
        pure
        returns (Schema.InitializeLayout storage $)
    {
        bytes32 slot = SCT_INITIALIZE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    bytes32 internal constant LETS_BASE_INITIALIZE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.LETSBaseInitialize")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function LETSBaseInitializeSlot()
        internal
        pure
        returns (Schema.InitializeLayout storage $)
    {
        bytes32 slot = LETS_BASE_INITIALIZE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    bytes32 internal constant LETS_SALE_BASE_INITIALIZE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.LETSSaleBaseInitialize")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function LETSSaleBaseInitializeSlot()
        internal
        pure
        returns (Schema.InitializeLayout storage $)
    {
        bytes32 slot = LETS_SALE_BASE_INITIALIZE_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
