// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IBeaconUpgradeableBaseStructs} from "../../BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";
import {ISCRStructs} from "./ISCRStructs.sol";

/**
 * @title SmartCompany Registry Functions v0.1.0
 */
interface ISCRFunctions {
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
            address[] memory services
        );

    /**
     * @notice Set the company info
     * @dev only founder can set the company info
     * @param scid The smart company number
     * @param field The field of the company info
     * @param value The value of the company info
     */
    function setCompanyInfo(
        string calldata scid,
        string calldata field,
        string calldata value
    ) external;

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

    /**
     * @notice Add the company info field
     * @dev only DEFAULT_ADMIN_ROLE can add the company info field
     * @param legalEntityCode The legal entity code
     * @param field The field of the company info
     */
    function addCompanyInfoFields(
        string calldata legalEntityCode,
        string calldata field
    ) external;

    /**
     * @notice Update the company info field
     * @dev only DEFAULT_ADMIN_ROLE can update the company info field
     * @param legalEntityCode The legal entity code
     * @param fieldIndex The field index of the company info
     * @param field The field of the company info
     */
    function updateCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex,
        string calldata field
    ) external;

    /**
     * @notice Delete the company info field
     * @dev only DEFAULT_ADMIN_ROLE can delete the company info field
     * @param legalEntityCode The legal entity code
     * @param fieldIndex The field index of the company info
     */
    function deleteCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex
    ) external;
}
