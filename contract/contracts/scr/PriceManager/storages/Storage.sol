// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";

/**
 * @title Borderless Price Manager Storage v0.1.0
 */
library Storage {
    bytes32 internal constant PRICE_MANAGER_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("erc7201:borderless:contracts.storage.PriceManager")) -
                    1
            )
        ) & ~bytes32(uint256(0xff));

    function priceManagerSlot() internal pure returns (Schema.PriceManagerLayout storage $) {
        bytes32 slot = PRICE_MANAGER_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
