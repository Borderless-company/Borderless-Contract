// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ISCRBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";


/**
 * @title SCRBeaconUpgradeableProxy
 * @notice SCRBeaconUpgradeableProxy is a proxy contract for the SCRBeaconUpgradeable contract.
 */
contract SCRBeaconUpgradeableProxy is ISCRBeaconUpgradeableFunctions {
    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function updateSCRBeaconName(
        address beacon,
        string memory name
    ) external override returns (IBeaconUpgradeableBaseStructs.Beacon memory beacon_) {}

    function changeSCRBeaconOnline(address beacon, bool isOnline) external {}

    // =============================================== //
    //            EXTERNAL READ FUNCTIONS              //
    // =============================================== //

    function getSCRBeacon(
        address beacon
    ) external view override returns (IBeaconUpgradeableBaseStructs.Beacon memory) {}

    function getSCRProxy(
        address proxy
    ) external view override returns (IBeaconUpgradeableBaseStructs.Proxy memory) {}
}