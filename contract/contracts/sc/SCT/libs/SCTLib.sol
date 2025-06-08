// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as SCTStorage} from "../storages/Storage.sol";

// lib
import {Address} from "../../../core/lib/Address.sol";

// interfaces
import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title SCT Library
 * @notice SCT is a library that manages the smart company template
 */
library SCTLib {
    // ============================================== //
    //            EXTERNAL WRITE FUNCTIONS            //
    // ============================================== //

    /**
     * @notice Register a service
     * @param serviceTypes The service types
     * @param services The service addresses
     * @return completed Whether the service is registered
     */
    function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) internal returns (bool completed) {
        for (uint256 index = 0; index < serviceTypes.length; index++) {
            address activatedAddress = services[index];
            Address.checkZeroAddress(activatedAddress);
            SCTStorage.SCTSlot().serviceContracts[serviceTypes[index]] = activatedAddress;
        }
        completed = true;
    }

    /**
     * @notice Set the investment amount
     * @param account The account
     * @param investmentAmount The investment amount
     */
    function setInvestmentAmount(
        address account,
        uint256 investmentAmount
    ) internal {
        SCTStorage.SCTSlot().investmentAmount[account] = investmentAmount;
    }

    // ============================================== //
    //            EXTERNAL READ FUNCTIONS             //
    // ============================================== //

    /**
     * @notice Get the SCR address
     * @return scr The SCR address
     */
    function getSCR() internal view returns (address scr) {
        scr = SCTStorage.SCTSlot().scr;
    }

    /**
     * @notice Get the service address
     * @param serviceType The service type
     * @return The service address
     */
    function getService(
        ServiceType serviceType
    ) internal view returns (address) {
        return SCTStorage.SCTSlot().serviceContracts[serviceType];
    }

    /**
     * @notice Get the investment amount
     * @param account The account
     * @return The investment amount
     */
    function getInvestmentAmount(
        address account
    ) internal view returns (uint256) {
        return SCTStorage.SCTSlot().investmentAmount[account];
    }
}
