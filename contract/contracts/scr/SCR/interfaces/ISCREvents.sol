// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @dev Interface for the SmartCompany Registry v0.1.0
 */
interface ISCREvents {
    // Note: EventSCR is an event interface
    /**
     * @dev Event when a new SmartCompany is created
     * @param founder Address of the caller who created the SmartCompany
     * @param company Address of the newly created SmartCompany
     * @param scid SCID of the newly created SmartCompany
     * @param services Deployed services addresses
     * @param serviceTypes Deployed services types
     */
    event DeploySmartCompany(
        address indexed founder,
        address indexed company,
        string scid,
        address[] services,
        ServiceType[] serviceTypes
    );
}
