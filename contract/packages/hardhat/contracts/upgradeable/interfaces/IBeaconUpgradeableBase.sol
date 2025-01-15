// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

interface IBeaconUpgradeableBase {
    // ============================================== //
    //                  Errors                        //
    // ============================================== //

    error InvalidImplementation(address _implementation);
    error InvalidName(string name);
    error BeaconAlreadyOnlineOrOffline(address _implementation);

    // ============================================== //
    //                  Events                        //
    // ============================================== //
    event ProxyCreated(address indexed proxyAddress, string name);

    event ProxyAdded(address indexed proxyAddress, string name);

    event BeaconNameUpdated(address indexed beaconAddress, string name);

    event BeaconOnline(address indexed beaconAddress);

    event BeaconOffline(address indexed beaconAddress);

    // ============================================== //
    //                    Struct                      //
    // ============================================== //

    struct Beacon {
        string name;
        address beacon;
        bool isOnline;
        uint256 proxyCount;
    }
}
