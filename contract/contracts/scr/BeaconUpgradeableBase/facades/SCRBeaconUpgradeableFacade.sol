// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ISCRBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {BeaconProxyFacade} from "../beacons/proxy/BeaconProxyFacade.sol";
/**
 * @title SCRBeaconUpgradeableFacade
 * @notice SCRBeaconUpgradeableFacade is a proxy contract for the SCRBeaconUpgradeable contract.
 */
contract SCRBeaconUpgradeableFacade is ISCRBeaconUpgradeableFunctions, BeaconProxyFacade {
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function setSCRProxyBeacon(address proxy, address beacon) external override {}

    function updateSCRBeaconName(
        address beacon,
        string memory name
    ) external override {}

    function updateSCRProxyName(
        address proxy,
        string memory name
    ) external override {}

    function changeSCRBeaconOnline(address beacon, bool isOnline) external {}

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    function getSCRBeacon(
        address beacon
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory)
    {}

    function getSCRProxy(
        address proxy
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {}

    function getScProxyBeacon(address scProxy) external view override returns (address beacon) {}
}
