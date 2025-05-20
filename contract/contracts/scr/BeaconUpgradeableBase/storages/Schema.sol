// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";

/**
 * @title Borderless Beacon Proxy Base Schema v0.1.0
 */
library Schema {
    struct BeaconProxyLayout {
        // Beacon Proxy Contract Address => Beacon Info
        mapping(address => IBeaconUpgradeableBaseStructs.Beacon) beacons;
        // Proxy Contract Address => Proxy Info
        mapping(address => IBeaconUpgradeableBaseStructs.Proxy) proxies;
    }
}
