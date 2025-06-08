// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {ServiceFactoryBeaconUpgradeableLib} from "../libs/ServiceFactoryBeaconUpgradeableLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";
import {ServiceFactoryLib} from "../../Factory/libs/ServiceFactoryLib.sol";

// interfaces
import {IBeaconUpgradeableBaseEvents} from "../interfaces/IBeaconUpgradeableBaseEvents.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {IServiceFactoryBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";
import {IErrors} from "../../../core/utils/IErrors.sol";
import {IBeaconProxyFunctions} from "../beacons/interfaces/IBeaconProxyFunctions.sol";

/**
 * @title ServiceFactoryBeaconUpgradeable
 * @notice This library contains functions for the ServiceFactoryBeaconUpgradeable contract v0.1.0.
 */
contract ServiceFactoryBeaconUpgradeable is
    IServiceFactoryBeaconUpgradeableFunctions
{
    // =============================================== //
    //                   MODIFIERS                     //
    // =============================================== //

    /**
     * @dev only admin can call this function
     */
    modifier onlyAdmin() {
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );
        _;
    }

    /**
     * @dev only founder can call this function
     */
    modifier onlyFounder(address proxy) {
        address beacon = IBeaconProxyFunctions(proxy).getBeacon();
        ServiceType serviceType = ServiceFactoryLib.getServiceType(beacon);
        address proxy_ = ServiceFactoryLib.getFounderService(msg.sender, serviceType);
        require(
            proxy == proxy_,
            IErrors.NotFounder(
                msg.sender
            )
        );
        _;
    }

    // =============================================== //
    //            EXTERNAL WRITE FUNCTIONS             //
    // =============================================== //

    function setServiceFactoryProxyBeacon(
        address proxy,
        address beacon
    ) external override onlyFounder(proxy) {
        ServiceFactoryBeaconUpgradeableLib.setServiceFactoryProxyBeacon(
            proxy,
            beacon
        );
    }

    function updateServiceFactoryBeaconName(
        address beacon,
        string calldata name
    ) external override onlyAdmin {
        ServiceFactoryBeaconUpgradeableLib.updateServiceFactoryBeaconName(
            beacon,
            name
        );

        // emit event
        emit IBeaconUpgradeableBaseEvents.BeaconNameUpdated(beacon, name);
    }

    function updateServiceFactoryProxyName(
        address proxy,
        string calldata name
    ) external override onlyFounder(proxy) {
        ServiceFactoryBeaconUpgradeableLib.updateServiceFactoryProxyName(
            proxy,
            name
        );
    }

    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) external override onlyAdmin {
        ServiceFactoryBeaconUpgradeableLib.changeServiceFactoryBeaconOnline(
            beacon,
            isOnline
        );

        // emit event
        if (isOnline) {
            emit IBeaconUpgradeableBaseEvents.BeaconOnline(beacon);
        } else {
            emit IBeaconUpgradeableBaseEvents.BeaconOffline(beacon);
        }
    }

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
    {
        return
            ServiceFactoryBeaconUpgradeableLib.getServiceFactoryBeacon(beacon);
    }

    function getServiceFactoryProxy(
        address proxy
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {
        return ServiceFactoryBeaconUpgradeableLib.getServiceFactoryProxy(proxy);
    }
}
