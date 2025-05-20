// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @dev Interface for the SmartCompany Registry v0.1.0
 */
interface ICompanyInfoEvents {
    /**
     * @dev Event when the company info is updated
     * @param founder Address of the founder
     * @param scid SCID of the company that is updated
     * @param companyInfoField Company info field that is updated
     * @param value Value of the company info field that is updated
     */
    event UpdateCompanyInfo(
        address indexed founder,
        string scid,
        string companyInfoField,
        string value
    );

    /**
     * @dev Event when the company info field is added
     * @param account Address of the account that added the company info field
     * @param legalEntityCode Legal entity code
     * @param field Added company info field
     */
    event AddCompanyInfoField(
        address indexed account,
        string legalEntityCode,
        string field
    );

    /**
     * @dev Event when the company info field is updated
     * @param account Address of the account that updated the company info field
     * @param fieldIndex Index of the updated company info field
     * @param legalEntityCode Legal entity code
     * @param field Updated company info field
     */
    event UpdateCompanyInfoField(
        address indexed account,
        uint256 indexed fieldIndex,
        string legalEntityCode,
        string field
    );

    /**
     * @dev Event when the company info field is deleted
     * @param account Address of the account that deleted the company info field
     * @param fieldIndex Index of the deleted company info field
     * @param legalEntityCode Legal entity code
     * @param field Deleted company info field
     */
    event DeleteCompanyInfoField(
        address indexed account,
        uint256 indexed fieldIndex,
        string legalEntityCode,
        string field
    );
}
