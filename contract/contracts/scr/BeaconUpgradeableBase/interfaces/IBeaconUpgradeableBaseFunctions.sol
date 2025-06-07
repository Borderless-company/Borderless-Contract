// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IBeaconUpgradeableBaseStructs} from "./IBeaconUpgradeableBaseStructs.sol";

/**
 * @title ISCRBeaconUpgradeableFunctions
 * @notice This interface contains the functions for the SCRBeaconUpgradeable contract v0.1.0.
 */
interface ISCRBeaconUpgradeableFunctions {
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    /**
     * @notice set the SCR proxy beacon
     * @param proxy the SCR proxy address
     * @param beacon the SCR beacon address
     */
    function setSCRProxyBeacon(address proxy, address beacon) external;

    /**
     * @notice update the SCR beacon name
     * @param beacon the SCR beacon address
     * @param name the SCR beacon name
     */
    function updateSCRBeaconName(address beacon, string memory name) external;

    /**
     * @notice update the SCR proxy name
     * @param proxy the SCR proxy address
     * @param name the SCR proxy name
     */
    function updateSCRProxyName(address proxy, string memory name) external;

    /**
     * @notice change the SCR beacon online status
     * @param beacon the SCR beacon address
     * @param isOnline the SCR beacon online status
     */
    function changeSCRBeaconOnline(address beacon, bool isOnline) external;

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    /**
     * @notice get the SCR beacon
     * @param beacon the SCR beacon proxy address
     * @return beacon the SCR beacon
     */
    function getSCRBeacon(
        address beacon
    ) external view returns (IBeaconUpgradeableBaseStructs.Beacon memory);

    /**
     * @notice get the SCR proxy
     * @param proxy the SCR proxy address
     * @return proxy the SCR proxy
     */
    function getSCRProxy(
        address proxy
    ) external view returns (IBeaconUpgradeableBaseStructs.Proxy memory);

    /**
     * @notice get the SCR proxy beacon
     * @param scProxy the SCR proxy address
     * @return beacon the SCR beacon address
     */
    function getScProxyBeacon(address scProxy) external view returns (address beacon);
}

interface IServiceFactoryBeaconUpgradeableFunctions {
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    /**
     * @notice set the service factory proxy beacon
     * @param proxy the service factory proxy address
     * @param beacon the service factory beacon address
     */
    function setServiceFactoryProxyBeacon(address proxy, address beacon) external;

    /**
     * @notice update the service factory beacon name
     * @param beacon the service factory beacon address
     * @param name the service factory beacon name
     */
    function updateServiceFactoryBeaconName(
        address beacon,
        string memory name
    ) external;

    /**
     * @notice update the service factory proxy name
     * @param proxy the service factory proxy address
     * @param name the service factory proxy name
     */
    function updateServiceFactoryProxyName(
        address proxy,
        string memory name
    ) external;

    /**
     * @notice change the service factory beacon online status
     * @param beacon the service factory beacon address
     * @param isOnline the service factory beacon online status
     */
    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) external;

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    /**
     * @notice get the service factory beacon
     * @param beacon the service factory beacon proxy address
     * @return beacon the service factory beacon
     */
    function getServiceFactoryBeacon(
        address beacon
    ) external view returns (IBeaconUpgradeableBaseStructs.Beacon memory);

    /**
     * @notice get the service factory proxy
     * @param proxy the proxy address
     * @return proxy the proxy
     */
    function getServiceFactoryProxy(
        address proxy
    ) external view returns (IBeaconUpgradeableBaseStructs.Proxy memory);
}
