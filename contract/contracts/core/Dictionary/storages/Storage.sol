// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title AccessControlUpgradeable Storage v0.1.0
 */
library Storage {
    bytes32 internal constant DICTIONARY_BASE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:openzeppelin:contracts.storage.DictionaryCore"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 internal constant DICTIONARY_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:openzeppelin:contracts.storage.Dictionary"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function DictionaryBaseSlot()
        internal
        pure
        returns (Schema.DictionaryBaseLayout storage $)
    {
        bytes32 slot = DICTIONARY_BASE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    function DictionarySlot()
        internal
        pure
        returns (Schema.DictionaryLayout storage $)
    {
        bytes32 slot = DICTIONARY_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
