// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IServiceFactoryBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {BeaconProxyFacade} from "../beacons/proxy/BeaconProxyFacade.sol";

/**
 * @title ServiceFactoryBeaconUpgradeableFacade
 * @notice ServiceFactoryBeaconUpgradeableFacade is a proxy contract for the ServiceFactoryBeaconUpgradeable contract.
 */
contract ServiceFactoryBeaconUpgradeableFacade is
    IServiceFactoryBeaconUpgradeableFunctions,
    BeaconProxyFacade
{
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function setServiceFactoryProxyBeacon(
        address proxy,
        address beacon
    ) external override {}

    function updateServiceFactoryBeaconName(
        address beacon,
        string memory name
    ) external override {}

    function updateServiceFactoryProxyName(
        address proxy,
        string memory name
    ) external override {}

    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) external {}

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    function getServiceFactoryBeacon(
        address beacon
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory)
    {}

    function getServiceFactoryProxy(
        address proxy
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {}
}
