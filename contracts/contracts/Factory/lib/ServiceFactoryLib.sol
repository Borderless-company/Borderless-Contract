// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage} from "../storages/Storage.sol";
import {Schema} from "../storages/Schema.sol";
import {Storage as BeaconUpgradeableBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";
import {Storage as AddressManagerStorage} from "../../AddressManager/storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/lib/BeaconUpgradeableBaseLib.sol";
import {AddressManagerLib} from "../../AddressManager/lib/AddressManagerLib.sol";

// interfaces
import {IServiceFactoryErrors} from "../interfaces/IServiceFactoryErrors.sol";
import {IServiceFactoryEvents} from "../interfaces/IServiceFactoryEvents.sol";
import {IServiceInitialize, ILETSSaleInitialize} from "../../utils/IServiceInitialize.sol";
import {ServiceType, ContractType} from "../../utils/ITypes.sol";
import {IBeaconUpgradeableBaseStructs} from "../../BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";

library ServiceFactoryLib {
    /**
     * @dev Activate service
     * @param founder Founder address
     * @param company Company address
     * @param beacon Beacon address
     * @param scsDeployParam Extra params
     * @return service Service address
     */
    function activate(
        address founder,
        address company,
        address beacon,
        bytes memory scsDeployParam
    ) internal returns (address service, ServiceType serviceType) {
        IBeaconUpgradeableBaseStructs.Beacon
            memory beaconInfo = BeaconUpgradeableBaseStorage.ServiceFactoryBeaconProxySlot().beacons[beacon];
        serviceType = Storage.ServiceFactorySlot().serviceTypes[beacon];

        // if the same type of service contract is already deployed, error
        if (serviceType != ServiceType.LETS_SALE) {
            require(
                ServiceFactoryLib.getFounderService(founder, serviceType) ==
                    address(0),
            IServiceFactoryErrors.AlreadyDeployedService(
                founder,
                beacon,
                serviceType
                )
            );
        }

        // prepare init data
        bytes memory initData = abi.encodeWithSelector(
            IServiceInitialize(beaconInfo.implementation).initialize.selector,
            founder,
            company,
            scsDeployParam
        );

        // Deploy new sc contract
        service = BeaconUpgradeableBaseLib.createProxy(
            BeaconUpgradeableBaseStorage.ServiceFactoryBeaconProxySlot(),
            beacon,
            initData
        );
        require(
            service != address(0),
            IServiceFactoryErrors.FailDeployService(
                msg.sender,
                company,
                beacon
            )
        );

        Storage.ServiceFactorySlot().founderServices[founder][
            serviceType
        ] = service;


        emit IServiceFactoryEvents.ActivateService(
            beacon,
            service
        );
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
