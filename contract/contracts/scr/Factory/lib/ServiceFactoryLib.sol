// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage} from "../storages/Storage.sol";
import {Schema} from "../storages/Schema.sol";
import {Storage as BeaconUpgradeableBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/lib/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IServiceFactoryErrors} from "../interfaces/IServiceFactoryErrors.sol";
import {IServiceFactoryEvents} from "../interfaces/IServiceFactoryEvents.sol";
import {IServiceInitialize} from "../../../core/utils/IServiceInitialize.sol";
import {ServiceType, ContractType} from "../../../core/utils/ITypes.sol";
import {IBeaconUpgradeableBaseStructs} from "../../BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";

library ServiceFactoryLib {
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

        Storage.ServiceFactorySlot().founderServices[founder][
            serviceType
        ] = service;

        emit IServiceFactoryEvents.ActivateService(beacon, service);
    }

    function getServiceType(
        address beacon
    ) internal view returns (ServiceType) {
        return Storage.ServiceFactorySlot().serviceTypes[beacon];
    }

    function getFounderService(
        address founder,
        ServiceType serviceType
    ) internal view returns (address) {
        return
            Storage.ServiceFactorySlot().founderServices[founder][serviceType];
    }
}
