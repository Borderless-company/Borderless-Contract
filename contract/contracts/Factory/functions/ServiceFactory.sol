// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../BorderlessAccessControl/storages/Storage.sol";
import {Storage as BeaconProxyBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {ServiceFactoryLib} from "../lib/ServiceFactoryLib.sol";
import {AccessControlLib} from "../../BorderlessAccessControl/lib/AccessControlLib.sol";
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/lib/BeaconUpgradeableBaseLib.sol";

// interfaces
import {IServiceFactory} from "../interfaces/IServiceFactory.sol";

// utils
import {ServiceType} from "../../utils/ITypes.sol";
import {Constants} from "../../lib/Constants.sol";

// OpenZeppelin
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ServiceFactory is Initializable, IServiceFactory {
    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ============================================== //
    //                   Initializer                  //
    // ============================================== //

    /**
     * @notice Initialize the Service Factory
     */
    function initialize() external initializer {}

    // ============================================== //
    //           External Write Functions             //
    // ============================================== //

    function setService(
        address implementation,
        string calldata name,
        ServiceType serviceType
    ) external override returns (address beacon) {
        // check role
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        beacon = BeaconUpgradeableBaseLib.createBeaconProxy(
            BeaconProxyBaseStorage.ServiceFactoryBeaconProxySlot(),
            implementation,
            name
        );

        Storage.ServiceFactorySlot().serviceTypes[beacon] = serviceType;
    }

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    function getServiceType(
        address beacon
    ) external view returns (ServiceType) {
        return ServiceFactoryLib.getServiceType(beacon);
    }

    function getFounderService(
        address founder,
        ServiceType serviceType
    ) external view returns (address) {
        return ServiceFactoryLib.getFounderService(founder, serviceType);
    }
}
