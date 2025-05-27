// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title SmartCompany Registry Functions v0.1.0
 */
interface ISCRFunctions {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    /**
     * @notice Create a new SmartCompany
     * @dev only executor can create a new SmartCompany
     * @param scid The smart company identifier
     * @param scBeaconProxy The smart company beacon proxy address
     * @param legalEntityCode The legal entity code
     * @param companyName The company name
     * @param establishmentDate The date of incorporation
     * @param jurisdiction The jurisdiction
     * @param entityType The entity type
     * @param scDeployParams The deploy params. [sc deploy params, ...sc deploy params]
     * @param companyInfo The company info
     * @param scsBeaconProxy The smart company service contract beacon proxy addresses
     * @param scsDeployParams The deploy params. [scs deploy params, ...scs deploy params]
     * @return companyAddress The smart company address
     * @return services The smart company services addresses
     * @return serviceTypes The smart company service types
     */
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
            address companyAddress,
            address[] memory services,
            ServiceType[] memory serviceTypes
        );

    /**
     * @notice Set the Smart Company contract
     * @dev only DEFAULT_ADMIN_ROLE can set the Smart Company contract
     * @param scImplementation The Smart Company contract implementation address
     * @param scName The Smart Company contract name
     * @return beacon The Smart Company beacon proxy address
     */
    function setSCContract(
        address scImplementation,
        string calldata scName
    ) external returns (address beacon);

    /**
     * @notice Update the Smart Company contract
     * @dev only DEFAULT_ADMIN_ROLE can update the Smart Company contract
     * @param scBeacon The Smart Company beacon proxy address
     * @param newSCImplementation The Smart Company contract implementation address
     */
    function updateSCContract(
        address scBeacon,
        address newSCImplementation
    ) external;

    // ============================================== //
    //           EXTERNAL READ FUNCTIONS              //
    // ============================================== //

    /**
     * @notice Get the smart company id
     * @param founder The founder address
     * @return scid The smart company identifier
     */
    function getSmartCompanyId(
        address founder
    ) external view returns (string memory scid);
}
