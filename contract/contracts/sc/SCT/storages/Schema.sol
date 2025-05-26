// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title Borderless SCT Schema v0.1.0
 */
library Schema {
    struct SCTLayout {
        /**
         * @dev SCR address
         */
        address scr;
        /**
         * @dev service type => service address
         */
        mapping(ServiceType serviceType => address service) serviceContracts;
        /**
         * @dev account => investment amount
         */
        mapping(address account => uint256 investmentAmount) investmentAmount;
    }
}
