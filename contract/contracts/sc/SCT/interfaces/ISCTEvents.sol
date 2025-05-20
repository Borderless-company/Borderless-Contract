// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title ISCT Events v0.1.0
 */
interface ISCTEvents {
    /**
     * @dev Notify that the service initialization is complete
     * @param company The address of the company that performed the service initialization
     * @param serviceTypes The types of services associated with the service initialization
     * @param services The addresses of the services associated with the service initialization
     */
    event RegisterService(
        address indexed company,
        ServiceType[] serviceTypes,
        address[] services
    );
}
