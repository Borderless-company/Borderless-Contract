// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @dev Interface for the SmartCompany Registry v0.1.0
 */
interface ISCRErrors {
    /**
     * @dev Error when the number of company info is invalid
     * @param expected Expected number of company info
     * @param length Actual number of company info
     */
    error InvalidCompanyInfoLength(uint256 expected, uint256 length);

    /**
     * @dev Error when the service is not activated
     * @param account Address of the account
     * @param company Address of the company
     * @param service Address of the service
     */
    error NotActivateService(address account, address company, address service);

    /**
     * @dev Error when the scid is already used
     * @param scid The Smart Company ID
     */
    error AlreadyRegisteredScid(string scid);

    /**
     * @dev Error when invalid founder is provided
     * @param founder Address of the founder
     */
    error InvalidFounder(address founder);

    /**
     * @dev Error when SmartCompany cannot be established
     * @param scid The Smart Company ID
     */
    error FailedDeploySmartCompany(string scid);

    /**
     * @dev Error when already established SmartCompany is provided
     * @param founder Address of the founder
     * @param scid The Smart Company ID
     */
    error AlreadyEstablish(address founder, string scid);

    /**
     * @dev Error when SmartCompany is not online
     * @param beacon Address of the SmartCompany beacon proxy
     */
    error SmartCompanyNotOnline(address beacon);
}
