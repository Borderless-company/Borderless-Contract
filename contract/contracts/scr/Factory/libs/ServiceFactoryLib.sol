// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage} from "../storages/Storage.sol";
import {Schema} from "../storages/Schema.sol";
import {Storage as BeaconUpgradeableBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/libs/BeaconUpgradeableBaseLib.sol";
import {ServiceFactoryBeaconUpgradeableLib} from "../../BeaconUpgradeableBase/libs/ServiceFactoryBeaconUpgradeableLib.sol";

// interfaces
import {IServiceFactoryErrors} from "../interfaces/IServiceFactoryErrors.sol";
import {IServiceFactoryEvents} from "../interfaces/IServiceFactoryEvents.sol";
import {IServiceInitialize} from "../../../core/utils/IServiceInitialize.sol";
import {ServiceType, ContractType} from "../../../core/utils/ITypes.sol";
import {IBeaconUpgradeableBaseStructs} from "../../BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";

library ServiceFactoryLib {
    // ============================================== //
    //                 WRITE FUNCTIONS                //
    // ============================================== //

    /**
     * @dev Activate service
     * @param founder Founder address
     * @param company Company address
     * @param beacon Beacon address
     */
    function activate(
        address founder,
        address company,
        address beacon
    ) internal returns (address service, ServiceType serviceType) {
        serviceType = Storage.ServiceFactorySlot().serviceTypes[beacon];

        // Deploy new sc contract
        service = BeaconUpgradeableBaseLib.createProxy(
            BeaconUpgradeableBaseStorage.ServiceFactoryBeaconProxySlot(),
            beacon,
            ""
        );
        require(
            service != address(0),
            IServiceFactoryErrors.FailDeployService(msg.sender, company, beacon)
        );

        setFounderService(founder, serviceType, service);

        ServiceFactoryBeaconUpgradeableLib.setServiceFactoryProxyBeacon(
            service,
            beacon
        );

        emit IServiceFactoryEvents.ActivateService(beacon, service);
    }

    /**
     * @notice set the founder service
     * @param founder the founder address
     * @param serviceType the service type
     * @param service the service address
     */
    function setFounderService(
        address founder,
        ServiceType serviceType,
        address service
    ) internal {
        Storage.ServiceFactorySlot().founderServices[founder][
            serviceType
        ] = service;
    }

    // ============================================== //
    //                 READ FUNCTIONS                 //
    // ============================================== //

    /**
     * @notice get the service type
     * @param beacon the beacon address
     * @return serviceType the service type
     */
    function getServiceType(
        address beacon
    ) internal view returns (ServiceType) {
        return Storage.ServiceFactorySlot().serviceTypes[beacon];
    }

    /**
     * @notice get the founder service
     * @param founder the founder address
     * @param serviceType the service type
     * @return service the service address
     */
    function getFounderService(
        address founder,
        ServiceType serviceType
    ) internal view returns (address) {
        return
            Storage.ServiceFactorySlot().founderServices[founder][serviceType];
    }

    /**
     * @notice get the lets sale beacon
     * @param letsBeacon the lets beacon address
     * @return letsSaleBeacon the lets sale beacon address
     */
    function getLetsSaleBeacon(
        address letsBeacon
    ) internal view returns (address) {
        return Storage.ServiceFactorySlot().letsSaleBeacons[letsBeacon];
    }
}
