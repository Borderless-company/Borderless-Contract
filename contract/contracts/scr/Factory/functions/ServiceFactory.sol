// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../../core/BorderlessAccessControl/storages/Storage.sol";
import {Storage as BeaconProxyBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {ServiceFactoryLib} from "../lib/ServiceFactoryLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/lib/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IServiceFactory} from "../interfaces/IServiceFactory.sol";

// utils
import {ServiceType} from "../../../core/utils/ITypes.sol";
import {Constants} from "../../../core/lib/Constants.sol";

contract ServiceFactory is IServiceFactory {
    // ============================================== //
    //           External Write Functions             //
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

        Storage.ServiceFactorySlot().serviceTypes[beacon] = serviceType;
    }

    function setLetsSaleBeacon(
        address letsBeacon,
        address letsSaleBeacon
    ) external override {
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        Storage.ServiceFactorySlot().letsSaleBeacons[letsBeacon] = letsSaleBeacon;
    }

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    function getServiceType(
        address beacon
    ) external view returns (ServiceType) {
        return ServiceFactoryLib.getServiceType(beacon);
    }

    function getFounderService(
        address founder,
        ServiceType serviceType
    ) external view returns (address) {
        return ServiceFactoryLib.getFounderService(founder, serviceType);
    }
}
