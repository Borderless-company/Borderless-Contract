// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Schema} from "../storages/Schema.sol";
import {Storage as SCTStorage} from "../storages/Storage.sol";
import {Storage as ACStorage} from "../../../core/BorderlessAccessControl/storages/Storage.sol";

// lib
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";

// interfaces
import {ISCT} from "../interfaces/ISCT.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title SCT (Smart Company Template) contract
 */
contract SCT is ISCT {
    // ============================================== //
    //            External Write Functions            //
    // ============================================== //

    function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) external returns (bool completed) {
        require(
            BorderlessAccessControlLib.hasRole(
                Constants.FOUNDER_ROLE,
                msg.sender
            ) || msg.sender == SCTStorage.SCTSlot().scr,
            NotFounderOrSCR(msg.sender)
        );
        for (uint256 index = 0; index < serviceTypes.length; index++) {
            address activatedAddress = services[index];
            require(
                activatedAddress != address(0),
                InvalidAddress(activatedAddress)
            );
            SCTStorage.SCTSlot().serviceContracts[serviceTypes[index]] = activatedAddress;
        }
        emit RegisterService(address(this), serviceTypes, services);
        completed = true;
    }

    function setInvestmentAmount(
        address account,
        uint256 investmentAmount
    ) external {
        BorderlessAccessControlLib.onlyRole(
            Constants.TREASURY_ROLE,
            msg.sender
        );
        SCTStorage.SCTSlot().investmentAmount[account] = investmentAmount;
    }

    // ============================================== //
    //            External Read Functions             //
    // ============================================== //

    function getSCR() external view returns (address scr) {
        scr = SCTStorage.SCTSlot().scr;
    }

    function getService(
        ServiceType serviceType
    ) external view returns (address) {
        return SCTStorage.SCTSlot().serviceContracts[serviceType];
    }

    function getInvestmentAmount(
        address account
    ) external view returns (uint256) {
        return SCTStorage.SCTSlot().investmentAmount[account];
    }
}
