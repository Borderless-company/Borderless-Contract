// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title SmartCompany Registry Functions v0.1.0
 */
interface ICompanyInfoFunctions {
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
