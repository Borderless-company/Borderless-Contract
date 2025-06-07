// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IBeaconUpgradeableBaseEvents {
    // ============================================== //
    //                  Events                        //
    // ============================================== //

    /**
     * @dev emitted when a beacon is upgraded
     * @param implementation the address of the implementation
     * @param newImplementation the address of the new implementation
     */
    event BeaconUpgraded(
        address indexed implementation,
        address indexed newImplementation
    );

    /**
     * @dev emitted when a proxy is created
     * @param beacon the address of the beacon
     * @param name the name of the beacon
     */
    event DeployBeaconProxy(address indexed beacon, string name);

    /**
     * @dev emitted when a proxy is added
     * @param proxy the address of the proxy
     * @param name the name of the proxy
     */
    event DeployProxy(address indexed proxy, string name);

    /**
     * @dev emitted when the name of a beacon is updated
     * @param beacon the address of the beacon
     * @param name the new name of the beacon
     */
    event BeaconNameUpdated(address indexed beacon, string name);

    /**
     * @dev emitted when the name of a proxy is updated
     * @param proxy the address of the proxy
     * @param name the new name of the proxy
     */
    event ProxyNameUpdated(address indexed proxy, string name);

    /**
     * @dev emitted when a beacon is online
     * @param beacon the address of the beacon
     */
    event BeaconOnline(address indexed beacon);

    /**
     * @dev emitted when a beacon is offline
     * @param beacon the address of the beacon
     */
    event BeaconOffline(address indexed beacon);
}
