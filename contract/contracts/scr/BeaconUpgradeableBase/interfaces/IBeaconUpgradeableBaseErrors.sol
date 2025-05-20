// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IBeaconUpgradeableBaseErrors {
    // ============================================== //
    //                  Errors                        //
    // ============================================== //

    /**
     * @dev emitted when an invalid implementation is used
     * @param implementation the address of the implementation
     */
    error InvalidImplementation(address implementation);

    /**
     * @dev emitted when an invalid beacon is used
     * @param beacon the address of the beacon
     */
    error InvalidBeacon(address beacon);

    /**
     * @dev emitted when a beacon is already online or offline
     * @param beacon the address of the beacon
     */
    error BeaconAlreadyOnlineOrOffline(address beacon);
}
