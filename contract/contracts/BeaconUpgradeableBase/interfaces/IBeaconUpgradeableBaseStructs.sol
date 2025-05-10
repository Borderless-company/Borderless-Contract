// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IBeaconUpgradeableBaseStructs {
    // ============================================== //
    //                    Struct                      //
    // ============================================== //

    /**
     * @dev struct representing a beacon
     * @param name the name of the beacon
     * @param implementation the address of the implementation
     * @param isOnline whether the beacon is online
     * @param proxyCount the number of proxies created from the beacon
     */
    struct Beacon {
        string name;
        address implementation;
        bool isOnline;
        uint256 proxyCount;
    }

    /**
     * @dev struct representing a proxy
     * @param name the name of the proxy
     * @param beacon the address of the beacon
     */
    struct Proxy {
        string name;
        address beacon;
    }
}
