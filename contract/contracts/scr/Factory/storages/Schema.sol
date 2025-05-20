// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// utils
import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title Borderless Service Factory Schema v0.1.0
 */
library Schema {
    struct ServiceFactoryLayout {
        /**
         * @dev Service beacon => Service type
         */
        mapping(address serviceBeacon => ServiceType serviceType) serviceTypes;
        /**
         * @dev Founder => Service type => Service address
         */
        mapping(address founder => mapping(ServiceType serviceType => address service)) founderServices;

        /**
         * @dev LETS beacon => LETS sale beacon
         */
        mapping(address letsBeacon => address letsSaleBeacon) letsSaleBeacons;
    }
}
