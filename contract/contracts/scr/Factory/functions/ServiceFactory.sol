// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as ServiceFactoryStorage} from "../storages/Storage.sol";
import {Storage as BeaconProxyBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {ServiceFactoryLib} from "../libs/ServiceFactoryLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/libs/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IServiceFactory} from "../interfaces/IServiceFactory.sol";

// utils
import {ServiceType} from "../../../core/utils/ITypes.sol";
import {Constants} from "../../../core/lib/Constants.sol";

/**
 * @title ServiceFactory
 * @notice This library contains functions for the ServiceFactory contract v0.1.0.
 */
contract ServiceFactory is IServiceFactory {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function setService(
        address implementation,
        string calldata name,
        ServiceType serviceType
    ) external override returns (address beacon) {
        // check role
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        beacon = BeaconUpgradeableBaseLib.createBeaconProxy(
            BeaconProxyBaseStorage.ServiceFactoryBeaconProxySlot(),
            implementation,
            name
        );

        ServiceFactoryStorage.ServiceFactorySlot().serviceTypes[beacon] = serviceType;
    }

    function setLetsSaleBeacon(
        address letsBeacon,
        address letsSaleBeacon
    ) external override {
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        ServiceFactoryStorage.ServiceFactorySlot().letsSaleBeacons[letsBeacon] = letsSaleBeacon;
    }

    // ============================================== //
    //           EXTERNAL READ FUNCTIONS              //
    // ============================================== //

    function getServiceType(
        address beacon
    ) external view override returns (ServiceType) {
        return ServiceFactoryLib.getServiceType(beacon);
    }

    function getFounderService(
        address founder,
        ServiceType serviceType
    ) external view override returns (address) {
        return ServiceFactoryLib.getFounderService(founder, serviceType);
    }

    function getLetsSaleBeacon(
        address letsBeacon
    ) external view override returns (address) {
        return ServiceFactoryLib.getLetsSaleBeacon(letsBeacon);
    }
}
