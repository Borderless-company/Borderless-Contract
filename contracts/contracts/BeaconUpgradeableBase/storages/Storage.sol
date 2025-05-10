// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "./Schema.sol";
import {ContractType} from "../../utils/ITypes.sol";

/**
 * @title Borderless Beacon Proxy Base Storage v0.1.0
 */
library Storage {
    bytes32 internal constant SCR_BEACON_PROXY_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:borderless:contracts.storage.SCRBeaconProxy"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    bytes32 internal constant SERVICE_FACTORY_BEACON_PROXY_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "erc7201:borderless:contracts.storage.serviceFactoryBeaconProxy"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function SCRBeaconProxySlot()
        internal
        pure
        returns (Schema.BeaconProxyLayout storage $)
    {
        bytes32 slot = SCR_BEACON_PROXY_SLOT;
        assembly {
            $.slot := slot
        }
    }

    function ServiceFactoryBeaconProxySlot()
        internal
        pure
        returns (Schema.BeaconProxyLayout storage $)
    {
        bytes32 slot = SERVICE_FACTORY_BEACON_PROXY_SLOT;
        assembly {
            $.slot := slot
        }
    }
}
