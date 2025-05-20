// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IBeaconUpgradeableBaseStructs} from "./IBeaconUpgradeableBaseStructs.sol";

interface ISCRBeaconUpgradeableFunctions {
    // =============================================== //
    //            External Write Functions             //
    // =============================================== //
    /**
     * @notice update the SCR beacon name
     * @param beacon the SCR beacon address
     * @param name the SCR beacon name
     * @return beacon_ the SCR beacon
     */
    function updateSCRBeaconName(
        address beacon,
        string memory name
    ) external returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_);

    /**
     * @notice change the SCR beacon online status
     * @param beacon the SCR beacon address
     * @param isOnline the SCR beacon online status
     */
    function changeSCRBeaconOnline(address beacon, bool isOnline) external;

    // =============================================== //
    //            External Read Functions              //
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
}

interface IServiceFactoryBeaconUpgradeableFunctions {
    // =============================================== //
    //            External Write Functions             //
    // =============================================== //

    /**
     * @notice update the service factory beacon name
     * @param beacon the service factory beacon address
     * @param name the service factory beacon name
     * @return beacon_ the service factory beacon
     */
    function updateServiceFactoryBeaconName(
        address beacon,
        string memory name
    ) external returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_);

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
    //            External Read Functions              //
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
