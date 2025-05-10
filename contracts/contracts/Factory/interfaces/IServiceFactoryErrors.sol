// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../utils/ITypes.sol";

/**
 * @dev Interface for the Service Factory v0.1.0
 */
interface IServiceFactoryErrors {
    /**
     * @dev Error informing that the service has not been activated.
     * @param account The address of the account that caused the error.
     * @param company The address of the company that caused the error.
     * @param beacon The address of the beacon that caused the error.
     */
    error FailDeployService(address account, address company, address beacon);

    /**
     * @dev Error informing that the service is not online.
     * @param beacon The address of the beacon that caused the error.
     */
    error ServiceNotOnline(address beacon);

    /**
     * @dev Error when already established SmartCompany is provided
     * @param founder Address of the founder
     * @param beacon Address of the already established SmartCompany
     * @param serviceType Type of the already established SmartCompany
     */
    error AlreadyDeployedService(
        address founder,
        address beacon,
        ServiceType serviceType
    );

    /**
     * @dev Error when the service is not governance.
     * @param beacon The address of the beacon that caused the error.
     */
    error NotGovernanceService(address beacon);
}
