// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title OpenZeppelin ERC721 Storage v0.1.0
 */
library Storage {
    bytes32 internal constant ERC721_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("erc7201:borderless:contracts.storage.ERC721")
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 internal constant ERC721_URI_STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:borderless:contracts.storage.ERC721URIStorage"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 internal constant ERC721_ENUMERABLE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:borderless:contracts.storage.ERC721Enumerable"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function ERC721Slot()
        internal
        pure
        returns (Schema.ERC721Layout storage $)
    {
        bytes32 slot = ERC721_SLOT;
        assembly {
            $.slot := slot
        }
    }

    function ERC721URIStorageSlot()
        internal
        pure
        returns (Schema.ERC721URIStorageLayout storage $)
    {
        bytes32 slot = ERC721_URI_STORAGE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    function ERC721EnumerableSlot()
        internal
        pure
        returns (Schema.ERC721EnumerableLayout storage $)
    {
        bytes32 slot = ERC721_ENUMERABLE_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
