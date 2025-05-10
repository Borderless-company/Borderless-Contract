// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title SmartCompany Registry Structs v0.1.0
 */
interface ISCRStructs {
    /**
     * @dev company info
     * @param companyAddress Company address
     * @param founder Founder address
     * @param establishmentDate Date of incorporation
     * @param jurisdiction Jurisdiction
     * @param entityType Entity type
     * @param createAt Create at
     */
    struct CompanyInfo {
        string companyName;
        address companyAddress;
        address founder;
        string establishmentDate;
        string jurisdiction;
        string entityType;
        uint256 createAt;
        uint256 updateAt;
    }
}
