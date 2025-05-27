// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IServiceFactoryFunctions} from "../interfaces/IServiceFactoryFunctions.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title ServiceFactoryProxy
 * @notice ServiceFactoryProxy is a proxy contract for the ServiceFactory contract.
 */
contract ServiceFactoryProxy is IServiceFactoryFunctions {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function setService(
        address implementation,
        string calldata name,
        ServiceType serviceType
    ) external returns (address beacon) {}

    function setLetsSaleBeacon(
        address letsBeacon,
        address letsSaleBeacon
    ) external {}

    // ============================================== //
    //           EXTERNAL READ FUNCTIONS              //
    // ============================================== //

    function getServiceType(
        address beacon
    ) external view override returns (ServiceType) {}

    function getFounderService(
        address founder,
        ServiceType serviceType
    ) external view override returns (address) {}
}
