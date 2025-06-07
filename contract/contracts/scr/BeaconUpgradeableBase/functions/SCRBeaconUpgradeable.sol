// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as SCRBeaconStorage} from "../storages/Storage.sol";

// lib
import {BeaconUpgradeableBaseLib} from "../libs/BeaconUpgradeableBaseLib.sol";
import {SCRBeaconUpgradeableLib} from "../libs/SCRBeaconUpgradeableLib.sol";
import {CompanyInfoLib} from "../../SCR/libs/CompanyInfoLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";

// interfaces
import {IBeaconUpgradeableBaseEvents} from "../interfaces/IBeaconUpgradeableBaseEvents.sol";
import {IBeaconUpgradeableBaseErrors} from "../interfaces/IBeaconUpgradeableBaseErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../interfaces/IBeaconUpgradeableBaseStructs.sol";
import {ISCRBeaconUpgradeableFunctions} from "../interfaces/IBeaconUpgradeableBaseFunctions.sol";
import {ISCRFunctions} from "../../SCR/interfaces/ISCRFunctions.sol";
import {ICompanyInfo} from "../../SCR/interfaces/CompanyInfo/ICompanyInfo.sol";
import {ICompanyInfoStructs} from "../../SCR/interfaces/CompanyInfo/ICompanyInfoStructs.sol";
import {IErrors} from "../../../core/utils/IErrors.sol";

/**
 * @title SCRBeaconUpgradeableFunctions
 * @notice This library contains functions for the SCRBeaconUpgradeable contract v0.1.0.
 */
contract SCRBeaconUpgradeable is ISCRBeaconUpgradeableFunctions {
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
        string memory scid = CompanyInfoLib.getSmartCompanyId(msg.sender);
        require(
            bytes(scid).length > 0,
            IBeaconUpgradeableBaseErrors.SmartCompanyIdNotFound(
                scid,
                msg.sender
            )
        );
        ICompanyInfoStructs.CompanyInfo memory companyInfo = CompanyInfoLib.getCompanyInfo(scid);
        require(
            companyInfo.founder == msg.sender,
            IErrors.NotFounder(
                msg.sender
            )
        );

        _;
    }

    // =============================================== //
    //                 WRITE FUNCTIONS                 //
    // =============================================== //

    function setSCRProxyBeacon(
        address proxy,
        address beacon
    ) external override onlyFounder(proxy) {
        SCRBeaconUpgradeableLib.setSCProxyBeacon(proxy, beacon);
    }

    function updateSCRBeaconName(
        address beacon,
        string calldata name
    ) external override onlyAdmin {
        SCRBeaconUpgradeableLib.updateSCRBeaconName(beacon, name);
        emit IBeaconUpgradeableBaseEvents.BeaconNameUpdated(beacon, name);
    }

    function updateSCRProxyName(
        address proxy,
        string calldata name
    ) external override onlyFounder(proxy) {
        SCRBeaconUpgradeableLib.updateSCRProxyName(proxy, name);
        emit IBeaconUpgradeableBaseEvents.ProxyNameUpdated(proxy, name);
    }

    function changeSCRBeaconOnline(
        address beacon,
        bool isOnline
    ) external override onlyAdmin {
        SCRBeaconUpgradeableLib.changeSCRBeaconOnline(beacon, isOnline);

        if (isOnline) {
            emit IBeaconUpgradeableBaseEvents.BeaconOnline(beacon);
        } else {
            emit IBeaconUpgradeableBaseEvents.BeaconOffline(beacon);
        }
    }

    // =============================================== //
    //                  READ FUNCTIONS                 //
    // =============================================== //

    function getSCRBeacon(
        address beacon
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Beacon memory)
    {
        return SCRBeaconUpgradeableLib.getSCRBeacon(beacon);
    }

    function getSCRProxy(
        address proxy
    )
        external
        view
        override
        returns (IBeaconUpgradeableBaseStructs.Proxy memory)
    {
        return SCRBeaconUpgradeableLib.getSCRProxy(proxy);
    }

    function getScProxyBeacon(
        address scProxy
    ) external view override returns (address beacon) {
        return SCRBeaconUpgradeableLib.getScProxyBeacon(scProxy);
    }
}
