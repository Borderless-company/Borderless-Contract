// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as ServiceFactoryBeaconStorage} from "../storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../libs/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";

library ServiceFactoryBeaconUpgradeableLib {
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    /**
     * @notice set the borderless proxy beacon
     * @param proxy the proxy address
     * @param beacon the beacon address
     */
    function setServiceFactoryProxyBeacon(
        address proxy,
        address beacon
    ) internal {
        BeaconUpgradeableBaseLib.setBorderlessProxyBeacon(
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot(),
            proxy,
            beacon
        );
    }

    /**
     * @notice Update the name of the service factory beacon
     * @param beacon The beacon address
     * @param name The new name
     */
    function updateServiceFactoryBeaconName(
        address beacon,
        string calldata name
    )
        internal
    {
        BeaconUpgradeableBaseLib.updateBeaconName(
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot(),
            beacon,
            name
        );
    }

    /**
     * @notice Update the name of the service factory proxy
     * @param proxy The proxy address
     * @param name The new name
     */
    function updateServiceFactoryProxyName(
        address proxy,
        string calldata name
    ) internal {
        BeaconUpgradeableBaseLib.updateProxyName(
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot(),
            proxy,
            name
        );
    }

    /**
     * @notice Change the online status of the service factory beacon
     * @param beacon The beacon address
     * @param isOnline The new online status
     */
    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) internal {
        BeaconUpgradeableBaseLib.changeSCRBeaconOnline(
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot(),
            beacon,
            isOnline
        );
    }

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    /**
     * @notice Get the service factory beacon
     * @param beacon The beacon address
     * @return The service factory beacon
     */
    function getServiceFactoryBeacon(
        address beacon
    )
        internal
        view
        returns (IBeaconUpgradeableBaseStructs.Beacon memory)
    {
        return
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot().beacons[
                beacon
            ];
    }

    /**
     * @notice Get the service factory proxy
     * @param proxy The proxy address
     * @return The service factory proxy
     */
    function getServiceFactoryProxy(
        address proxy
    )
        internal
        view
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {
        return
            ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot().proxies[
                proxy
            ];
    }

    /**
     * @notice get the sc proxy beacon
     * @param scProxy the sc proxy address
     * @return beacon the sc beacon address
     */
    function getScProxyBeacon(
        address scProxy
    ) internal view returns (address beacon) {
        return ServiceFactoryBeaconStorage.ServiceFactoryBeaconProxySlot().borderlessProxyBeacons[scProxy];
    }
}