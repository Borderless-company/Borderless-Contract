// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IServiceFactoryBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";

/**
 * @title ServiceFactoryBeaconUpgradeableProxy
 * @notice ServiceFactoryBeaconUpgradeableProxy is a proxy contract for the ServiceFactoryBeaconUpgradeable contract.
 */
contract ServiceFactoryBeaconUpgradeableProxy is IServiceFactoryBeaconUpgradeableFunctions {
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function updateServiceFactoryBeaconName(
        address beacon,
        string memory name
    ) external override returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_) {}

    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) external {}

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    function getServiceFactoryBeacon(
        address beacon
    ) external view override returns (IBeaconUpgradeableBaseStructs.Beacon memory) {}

    function getServiceFactoryProxy(
        address proxy
    ) external view override returns (IBeaconUpgradeableBaseStructs.Proxy memory) {}
}