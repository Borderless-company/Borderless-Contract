// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IBeaconProxyFunctions} from "./interfaces/IBeaconProxyFunctions.sol";

// Openzeppelin
import {BeaconProxy as BeaconProxyOZ} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract BeaconProxy is BeaconProxyOZ, IBeaconProxyFunctions {
    constructor(
        address beacon,
        bytes memory data
    ) BeaconProxyOZ(beacon, data) {}

    function getImplementation() external view override returns (address) {
        return _implementation();
    }

    function getBeacon() external view override returns (address) {
        return _getBeacon();
    }
}
