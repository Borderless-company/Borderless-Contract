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
        beacon_ = BeaconUpgradeableBaseLib.updateBeaconName(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            beacon,
            name
        );

        emit IBeaconUpgradeableBaseEvents.BeaconNameUpdated(beacon, name);
    }

    function changeSCRBeaconOnline(
        address beacon,
        bool isOnline
    ) external override {
        BeaconUpgradeableBaseLib.changeSCRBeaconOnline(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            beacon,
            isOnline
        );

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
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory)
    {
        return SCRBeaconStorage.SCRBeaconProxySlot().beacons[beacon];
    }

    function getSCRProxy(
        address proxy
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {
        return SCRBeaconStorage.SCRBeaconProxySlot().proxies[proxy];
    }
}
