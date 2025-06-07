// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as SCRBeaconStorage} from "../storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "./BeaconUpgradeableBaseLib.sol";

// interfaces
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";

/**
 * @title SCRBeaconUpgradeableLib v0.1.0
 * @notice This library contains functions for the SCRBeaconUpgradeable contract v0.1.0.
 */
library SCRBeaconUpgradeableLib {
    // =============================================== //
    //                  WRITE FUNCTIONS                //
    // =============================================== //

    /**
     * @notice set the borderless proxy beacon
     * @param proxy the proxy address
     * @param beacon the beacon address
     */
    function setSCProxyBeacon(
        address proxy,
        address beacon
    ) internal {
        BeaconUpgradeableBaseLib.setBorderlessProxyBeacon(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            proxy,
            beacon
        );
    }

    /**
     * @notice update the SCR beacon name
     * @param beacon the beacon address
     * @param name the new name
     * @return beacon_ the beacon
     */
    function updateSCRBeaconName(
        address beacon,
        string calldata name
    ) internal returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_) {
        beacon_ = BeaconUpgradeableBaseLib.updateBeaconName(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            beacon,
            name
        );
    }

    /**
     * @notice update the SCR proxy name
     * @param proxy the proxy address
     * @param name the new name
     */
    function updateSCRProxyName(address proxy, string calldata name) internal {
        BeaconUpgradeableBaseLib.updateProxyName(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            proxy,
            name
        );
    }

    /**
     * @notice change the SCR beacon online status
     * @param beacon the beacon address
     * @param isOnline the new online status
     */
    function changeSCRBeaconOnline(address beacon, bool isOnline) internal {
        BeaconUpgradeableBaseLib.changeSCRBeaconOnline(
            SCRBeaconStorage.SCRBeaconProxySlot(),
            beacon,
            isOnline
        );
    }

    // =============================================== //
    //                  READ FUNCTIONS                 //
    // =============================================== //

    /**
     * @notice get the SCR beacon
     * @param beacon the beacon address
     * @return beacon_ the beacon
     */
    function getSCRBeacon(
        address beacon
    ) internal view returns (IBeaconUpgradeableBaseStructs.Beacon memory) {
        return SCRBeaconStorage.SCRBeaconProxySlot().beacons[beacon];
    }

    /**
     * @notice get the SCR proxy
     * @param proxy the proxy address
     * @return proxy_ the proxy
     */
    function getSCRProxy(
        address proxy
    ) internal view returns (IBeaconUpgradeableBaseStructs.Proxy memory) {
        return SCRBeaconStorage.SCRBeaconProxySlot().proxies[proxy];
    }

    /**
     * @notice get the sc proxy beacon
     * @param scProxy the sc proxy address
     * @return beacon the sc beacon address
     */
    function getScProxyBeacon(
        address scProxy
    ) internal view returns (address beacon) {
        return SCRBeaconStorage.SCRBeaconProxySlot().borderlessProxyBeacons[scProxy];
    }
}
