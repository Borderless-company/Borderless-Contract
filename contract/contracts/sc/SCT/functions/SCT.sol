// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as SCTStorage} from "../storages/Storage.sol";

// lib
import {SCTLib} from "../libs/SCTLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";

// interfaces
import {ISCT} from "../interfaces/ISCT.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title SCT (Smart Company Template) contract
 * @notice SCT is a contract that manages the smart company template
 */
contract SCT is ISCT {
    // ============================================== //
    //            EXTERNAL WRITE FUNCTIONS            //
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
        completed = SCTLib.registerService(serviceTypes, services);
        emit RegisterService(address(this), serviceTypes, services);
    }

    function setInvestmentAmount(
        address account,
        uint256 investmentAmount
    ) external {
        BorderlessAccessControlLib.onlyRole(
            Constants.TREASURY_ROLE,
            msg.sender
        );
        SCTLib.setInvestmentAmount(account, investmentAmount);
    }

    // ============================================== //
    //            EXTERNAL READ FUNCTIONS             //
    // ============================================== //

    function getSCR() external view override returns (address scr) {
        scr = SCTLib.getSCR();
    }

    function getService(
        ServiceType serviceType
    ) external view override returns (address) {
        return SCTLib.getService(serviceType);
    }

    function getInvestmentAmount(
        address account
    ) external view override returns (uint256) {
        return SCTLib.getInvestmentAmount(account);
    }
}
