// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IBeaconProxyFunctions} from "../interfaces/IBeaconProxyFunctions.sol";

abstract contract BeaconProxyFacade is IBeaconProxyFunctions {
    function getImplementation() external view override returns (address) {}

    function getBeacon() external view override returns (address) {}
}
