// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as SCRBeaconStorage} from "../storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../lib/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IBeaconUpgradeableBaseEvents} from "../interfaces/IBeaconUpgradeableBaseEvents.sol";
import {IBeaconUpgradeableBaseErrors} from "../interfaces/IBeaconUpgradeableBaseErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {ISCRBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";

/**
 * @title SCRBeaconUpgradeableFunctions
 * @notice This library contains functions for the SCRBeaconUpgradeable contract v0.1.0.
 */
contract SCRBeaconUpgradeable is ISCRBeaconUpgradeableFunctions {

    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function updateSCRBeaconName(
        address beacon,
        string calldata name
    )
        external
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_)
    {
        BeaconUpgradeableBaseLib.checkBeacon(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            beacon,
            false
        );
        BeaconUpgradeableBaseLib.checkBeaconName(name);

        // update beacon name
        beacon_ = SCRBeaconStorage.SCRBeaconProxySlot().beacons[beacon];
        beacon_.name = name;

        // emit event
        emit IBeaconUpgradeableBaseEvents.BeaconNameUpdated(beacon, name);
    }

    function changeSCRBeaconOnline(
        address beacon,
        bool isOnline
    ) external override {
        // check if the beacon is already online or offline
        require(
            SCRBeaconStorage.SCRBeaconProxySlot().beacons[beacon].isOnline != isOnline,
            IBeaconUpgradeableBaseErrors.BeaconAlreadyOnlineOrOffline(beacon)
        );

        // change the beacon online status
        SCRBeaconStorage.SCRBeaconProxySlot().beacons[beacon].isOnline = isOnline;

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

    function getSCRBeacon(
        address beacon
    ) external override view returns (IBeaconUpgradeableBaseStructs.Beacon memory) {
        return SCRBeaconStorage.SCRBeaconProxySlot().beacons[beacon];
    }

    function getSCRProxy(
        address proxy
    ) external override view returns (IBeaconUpgradeableBaseStructs.Proxy memory) {
        return SCRBeaconStorage.SCRBeaconProxySlot().proxies[proxy];
    }
}
