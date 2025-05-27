// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ISCT} from "../interfaces/ISCT.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";

contract SCTProxy is ISCT {
    // ============================================== //
    //            EXTERNAL WRITE FUNCTIONS            //
    // ============================================== //

    function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) external returns (bool completed) {}

    function setInvestmentAmount(
        address account,
        uint256 investmentAmount
    ) external {}

    // ============================================== //
    //            EXTERNAL READ FUNCTIONS             //
    // ============================================== //

    function getSCR() external view returns (address scr) {}

    function getService(
        ServiceType serviceType
    ) external returns (address service) {}

    function getInvestmentAmount(
        address account
    ) external returns (uint256 investmentAmount) {}
}
