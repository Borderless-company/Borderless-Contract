// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IBeaconUpgradeableBaseErrors {
    // ============================================== //
    //                  Errors                        //
    // ============================================== //

    /**
     * @dev emitted when an invalid beacon is used
     * @param beacon the address of the beacon
     */
    error InvalidBeacon(address beacon, address implementation);

    /**
     * @dev emitted when a beacon is already online or offline
     * @param beacon the address of the beacon
     */
    error BeaconAlreadyOnlineOrOffline(address beacon);

    /**
     * @dev emitted when a smart company id is not found
     * @param scid the smart company id
     */
    error SmartCompanyIdNotFound(string scid, address account);
}
