// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IBeaconProxyFunctions
 * @notice Interface for the BeaconProxy contract
 */
interface IBeaconProxyFunctions {
    /**
     * @notice get the implementation address
     * @return the implementation address
     */
    function getImplementation() external view returns (address);

    /**
     * @notice get the beacon address
     * @return the beacon address
     */
    function getBeacon() external view returns (address);
}
