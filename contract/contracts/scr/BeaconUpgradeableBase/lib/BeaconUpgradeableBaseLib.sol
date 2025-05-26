// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Schema} from "../storages/Schema.sol";

// lib
import {Address} from "../../../core/lib/Address.sol";

// interfaces
import {IBeaconUpgradeableBaseEvents} from "../interfaces/IBeaconUpgradeableBaseEvents.sol";
import {IBeaconUpgradeableBaseErrors} from "../interfaces/IBeaconUpgradeableBaseErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {IErrors} from "../../../core/utils/IErrors.sol";

// Openzeppelin
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

// solady
import {LibString} from "solady/src/utils/LibString.sol";

/**
 * @title BeaconUpgradeableBaseLib
 * @notice This library contains functions for the BeaconUpgradeableBase contract v0.1.0.
 */
library BeaconUpgradeableBaseLib {
    // ============================================== //
    //                 Write Functions                //
    // ============================================== //

    /**
     * @notice add a beacon proxy
     * @param implementation the implementation address
     * @param name the beacon name
     * @return proxy the beacon proxy address
     */
    function createBeaconProxy(
        Schema.BeaconProxyLayout storage slot,
        address implementation,
        string memory name
    ) internal returns (address proxy) {
        // checkImplementation(implementation);
        checkBeaconName(name);

        // create beacon proxy
        UpgradeableBeacon beacon = new UpgradeableBeacon(
            implementation,
            msg.sender
        );

        // register beacon
        slot.beacons[address(beacon)] = IBeaconUpgradeableBaseStructs.Beacon({
            name: name,
            implementation: implementation,
            isOnline: true,
            proxyCount: 0
        });

        // emit event
        emit IBeaconUpgradeableBaseEvents.DeployBeaconProxy(
            address(beacon),
            name
        );
        return address(beacon);
    }

    /**
     * @notice create a proxy
     * @param beaconProxy the beacon proxy address
     * @param initData the init data
     * @return proxy the proxy address
     */
    function createProxy(
        Schema.BeaconProxyLayout storage slot,
        address beaconProxy,
        bytes memory initData
    ) internal returns (address proxy) {
        BeaconProxy _proxy = new BeaconProxy(beaconProxy, initData);
        proxy = address(_proxy);

        // register proxy
        // increase the proxy count
        slot.beacons[beaconProxy].proxyCount++;

        // get the beacon
        IBeaconUpgradeableBaseStructs.Beacon memory beacon = slot.beacons[
            beaconProxy
        ];

        // register proxy
        slot.proxies[proxy] = IBeaconUpgradeableBaseStructs.Proxy({
            name: beacon.name,
            beacon: beaconProxy
        });

        // emit event
        emit IBeaconUpgradeableBaseEvents.DeployProxy(proxy, beacon.name);
    }

    /**
     * @notice upgrade the beacon
     * @param beacon the beacon address
     * @param newImplementation the new implementation address
     */
    function upgradeBeacon(
        Schema.BeaconProxyLayout storage slot,
        address beacon,
        address newImplementation
    ) internal {
        checkBeacon(slot, beacon, false);
        // checkImplementation(newImplementation);

        // upgrade beacon proxy
        UpgradeableBeacon(payable(beacon)).upgradeTo(
            payable(newImplementation)
        );

        // update registered beacon
        slot.beacons[beacon].implementation = newImplementation;

        // emit event
        emit IBeaconUpgradeableBaseEvents.BeaconUpgraded(
            beacon,
            newImplementation
        );
    }

    // ============================================== //
    //                 Read Functions                 //
    // ============================================== //

    // function checkImplementation(address implementation) internal pure {
    //     require(
    //         Address.checkAddress(implementation),
    //         IBeaconUpgradeableBaseErrors.InvalidImplementation(implementation)
    //     );
    // }

    function checkBeacon(
        Schema.BeaconProxyLayout storage slot,
        address beacon,
        bool isAdd
    ) internal view {
        require(
            Address.checkAddress(beacon) &&
                (
                    isAdd
                        ? slot.beacons[beacon].implementation == address(0)
                        : slot.beacons[beacon].implementation != address(0)
                ),
            IBeaconUpgradeableBaseErrors.InvalidBeacon(beacon)
        );
    }

    function checkBeaconName(string memory name) internal pure {
        require(!LibString.eq(name, ""), IErrors.EmptyString(name));
    }
}
