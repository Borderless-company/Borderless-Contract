// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BeaconProxy} from "../beacons/BeaconProxy.sol";

// storages
import {Schema} from "../storages/Schema.sol";

// lib
import {Address} from "../../../core/lib/Address.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";

// interfaces
import {IBeaconUpgradeableBaseEvents} from "../interfaces/IBeaconUpgradeableBaseEvents.sol";
import {IBeaconUpgradeableBaseErrors} from "../interfaces/IBeaconUpgradeableBaseErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {IErrors} from "../../../core/utils/IErrors.sol";

// Openzeppelin
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

// solady
import {LibString} from "solady/src/utils/LibString.sol";

/**
 * @title BeaconUpgradeableBaseLib
 * @notice This library contains functions for the BeaconUpgradeableBase contract v0.1.0.
 */
library BeaconUpgradeableBaseLib {
    // ============================================== //
    //                 WRITE FUNCTIONS                //
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
        checkBeacon(slot, implementation, true);
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
     * @notice set the borderless proxy beacon
     * @param slot the beacon proxy layout
     * @param proxy the proxy address
     * @param beacon the beacon address
     */
    function setBorderlessProxyBeacon(
        Schema.BeaconProxyLayout storage slot,
        address proxy,
        address beacon
    ) internal {
        slot.borderlessProxyBeacons[proxy] = beacon;
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

    /**
     * @notice update the beacon name
     * @param slot the beacon proxy layout
     * @param beacon the beacon address
     * @param name the new name
     * @return beacon_ the beacon
     */
    function updateBeaconName(
        Schema.BeaconProxyLayout storage slot,
        address beacon,
        string memory name
    ) internal returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_) {
        onlyAdmin();
        checkBeacon(slot, beacon, false);
        checkBeaconName(name);
        slot.beacons[beacon].name = name;
        beacon_ = slot.beacons[beacon];
    }

    function updateProxyName(
        Schema.BeaconProxyLayout storage slot,
        address proxy,
        string memory name
    ) internal {
        slot.proxies[proxy].name = name;
    }

    /**
     * @notice change the beacon online status
     * @param slot the beacon proxy layout
     * @param beacon the beacon address
     * @param isOnline the new online status
     */
    function changeSCRBeaconOnline(
        Schema.BeaconProxyLayout storage slot,
        address beacon,
        bool isOnline
    ) internal {
        onlyAdmin();
        checkBeacon(slot, beacon, false);

        require(
            slot.beacons[beacon].isOnline != isOnline,
            IBeaconUpgradeableBaseErrors.BeaconAlreadyOnlineOrOffline(beacon)
        );

        slot.beacons[beacon].isOnline = isOnline;
    }

    // ============================================== //
    //                 READ FUNCTIONS                 //
    // ============================================== //

    /**
     * @dev check if the beacon is valid
     */
    function checkBeacon(
        Schema.BeaconProxyLayout storage slot,
        address beacon,
        bool isAdd
    ) internal view {
        require(
            !Address.isZeroAddress(beacon) &&
                (
                    isAdd
                        ? slot.beacons[beacon].implementation == address(0)
                        : slot.beacons[beacon].implementation != address(0)
                ),
            IBeaconUpgradeableBaseErrors.InvalidBeacon(
                beacon,
                slot.beacons[beacon].implementation
            )
        );
    }

    /**
     * @dev check if the caller is an admin
     */
    function onlyAdmin() internal view {
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );
    }

    /**
     * @dev check if the beacon name is not empty
     */
    function checkBeaconName(string memory name) internal pure {
        require(!LibString.eq(name, ""), IErrors.EmptyString(name));
    }
}
