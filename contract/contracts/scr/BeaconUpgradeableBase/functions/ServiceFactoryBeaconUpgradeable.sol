// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as ServiceFactoryBeaconStorage} from "../storages/Storage.sol";
import {Schema as ServiceFactoryBeaconSchema} from "../storages/Schema.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../lib/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IBeaconUpgradeableBaseEvents} from "../interfaces/IBeaconUpgradeableBaseEvents.sol";
import {IBeaconUpgradeableBaseErrors} from "../interfaces/IBeaconUpgradeableBaseErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {IServiceFactoryBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";

/**
 * @title ServiceFactoryBeaconUpgradeable
 * @notice This library contains functions for the ServiceFactoryBeaconUpgradeable contract v0.1.0.
 */
contract ServiceFactoryBeaconUpgradeable is
    IServiceFactoryBeaconUpgradeableFunctions
{
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function updateServiceFactoryBeaconName(
        address beacon,
        string calldata name
    )
        external
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_)
    {
        BeaconUpgradeableBaseLib.checkBeacon(
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot(),
            beacon,
            false
        );
        BeaconUpgradeableBaseLib.checkBeaconName(name);

        // update beacon name
        beacon_ = ServiceFactoryBeaconStorage
            .ServiceFactoryBeaconProxySlot()
            .beacons[beacon];
        beacon_.name = name;

        // emit event
        emit IBeaconUpgradeableBaseEvents.BeaconNameUpdated(beacon, name);
    }

    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) external override {
        // check if the beacon is already online or offline
        require(
            ServiceFactoryBeaconStorage
                .ServiceFactoryBeaconProxySlot()
                .beacons[beacon]
                .isOnline != isOnline,
            IBeaconUpgradeableBaseErrors.BeaconAlreadyOnlineOrOffline(beacon)
        );

        // change the beacon online status
        ServiceFactoryBeaconStorage
            .ServiceFactoryBeaconProxySlot()
            .beacons[beacon]
            .isOnline = isOnline;

        // emit event
        if (isOnline) {
            emit IBeaconUpgradeableBaseEvents.BeaconOnline(beacon);
        } else {
            emit IBeaconUpgradeableBaseEvents.BeaconOffline(beacon);
        }
    }

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    function getServiceFactoryBeacon(
        address beacon
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory)
    {
        return
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot().beacons[
                beacon
            ];
    }

    function getServiceFactoryProxy(
        address proxy
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {
        return
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot().proxies[
                proxy
            ];
    }
}
