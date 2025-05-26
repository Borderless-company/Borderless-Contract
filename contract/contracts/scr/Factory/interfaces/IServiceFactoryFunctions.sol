// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @dev Interface for the Service Factory v0.1.0
 */
interface IServiceFactoryFunctions {
    // ============================================== //
    //           External Write Functions             //
    // ============================================== //

    /**
     * @dev Set new service contract address
     * @param implementation Service implementation address
     * @param name Service name
     * @param serviceType Service type
     * @return beacon Beacon address
     */
    function setService(
        address implementation,
        string calldata name,
        ServiceType serviceType
    ) external returns (address beacon);

    /**
     * @dev Set lets sale beacon
     * @param letsBeacon LETS beacon address
     * @param letsSaleBeacon LETS sale beacon address
     */
    function setLetsSaleBeacon(
        address letsBeacon,
        address letsSaleBeacon
    ) external;

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    /**
     * @dev Get service type
     * @param beacon Beacon address
     * @return Service type
     */
    function getServiceType(address beacon) external view returns (ServiceType);

    /**
     * @dev Get founder service
     * @param founder Founder address
     * @param serviceType Service type
     * @return Service address
     */
    function getFounderService(
        address founder,
        ServiceType serviceType
    ) external view returns (address);
}
