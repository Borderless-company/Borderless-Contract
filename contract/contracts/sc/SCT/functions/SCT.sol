// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Schema} from "../storages/Schema.sol";
import {Storage as SCTStorage} from "../storages/Storage.sol";
import {Storage as ACStorage} from "../../../core/BorderlessAccessControl/storages/Storage.sol";

// lib
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";
import {SCInitializeLib} from "../../../core/Initialize/libs/SCInitializeLib.sol";

// interfaces
import {ISCT} from "../interfaces/ISCT.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";

import {console} from "hardhat/console.sol";

/**
 * @title SCT (Smart Company Template) contract
 */
contract SCT is ISCT {
    function initialize(address founder, address scr) external {
        SCInitializeLib.initialize(founder, scr);
    }
    // ============================================== //
    //            External Write Functions            //
    // ============================================== //

    function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) external returns (bool completed) {
        console.log("registerService");
        console.log("msg.sender", msg.sender);
        require(
            BorderlessAccessControlLib.hasRole(
                Constants.FOUNDER_ROLE,
                msg.sender
            ) || msg.sender == SCTStorage.SCTSlot().scr,
            NotFounderOrSCR(msg.sender)
        );
        console.log("check founder or scr");
        for (uint256 index = 0; index < serviceTypes.length; index++) {
            address activatedAddress = services[index];
            require(
                activatedAddress != address(0),
                InvalidAddress(activatedAddress)
            );
            console.log("check invalid address");
            SCTStorage.SCTSlot().serviceContracts[serviceTypes[index]] = activatedAddress;
        }
        console.log("set service contracts");
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
