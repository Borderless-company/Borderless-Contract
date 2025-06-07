// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ISCR} from "../interfaces/ISCR.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title SCRFacade
 * @notice SCRFacade is a proxy contract for the ISCR interface.
 */
contract SCRFacade is ISCR {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function createSmartCompany(
        string calldata scid,
        address scBeaconProxy,
        string calldata legalEntityCode,
        string calldata companyName,
        string calldata establishmentDate,
        string calldata jurisdiction,
        string calldata entityType,
        bytes calldata scDeployParams,
        string[] calldata companyInfo,
        address[] calldata scsBeaconProxy,
        bytes[] calldata scsDeployParams
    )
        external
        returns (
            address company,
            address[] memory services,
            ServiceType[] memory serviceTypes
        )
    {}

    function setSCContract(
        address scImplementation,
        string calldata scName
    ) external returns (address beacon) {}

    function updateSCContract(
        address scBeacon,
        address newSCImplementation
    ) external {}

    // ============================================== //
    //           EXTERNAL READ FUNCTIONS              //
    // ============================================== //

    function getSmartCompanyId(
        address founder
    ) external view returns (string memory scid) {}
}
