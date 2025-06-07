// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";

// interfaces
import {ICompanyInfo} from "../interfaces/CompanyInfo/ICompanyInfo.sol";

library CompanyInfoLib {
    // ============================================== //
    //                 WRITE FUNCTIONS                //
    // ============================================== //

    /**
     * @notice set the company info field
     * @param scid the sc id
     * @param companyInfoField the company info field
     * @param value the company info field value
     */
    function setCompanyInfoField(
        string calldata scid,
        string memory companyInfoField,
        string calldata value
    ) internal {
        Storage.SCRSlot().companiesInfo[scid][companyInfoField] = value;
    }

    /**
     * @notice set the company info
     * @param scid the sc id
     * @param companyInfo the company info
     */
    function setCompanyInfo(
        string calldata scid,
        ICompanyInfo.CompanyInfo memory companyInfo
    ) internal {
        Storage.SCRSlot().companies[scid] = companyInfo;
    }

    /**
     * @notice set the founder company
     * @param founder the founder address
     * @param scid the sc id
     */
    function setFounderCompany(
        address founder,
        string calldata scid
    ) internal {
        Storage.SCRSlot().founderCompanies[founder] = scid;
    }

    // ============================================== //
    //                 READ FUNCTIONS                 //
    // ============================================== //

    /**
     * @notice get the company info fields
     * @param legalEntityCode the legal entity code
     * @return fields the company info fields
     */
    function getCompanyInfoFields(
        string calldata legalEntityCode
    ) internal view returns (string[] memory fields) {
        return Storage.SCRSlot().companyInfoFields[legalEntityCode];
    }

    /**
     * @notice get the company info
     * @param scid the sc id
     * @return companyInfo the company info
     */
    function getCompanyInfo(
        string memory scid
    ) internal view returns (ICompanyInfo.CompanyInfo memory companyInfo) {
        return Storage.SCRSlot().companies[scid];
    }

    /**
     * @notice get the company field
     * @param scid the sc id
     * @param companyInfoField the company info field
     * @return value the company field value
     */
    function getCompanyField(
        string calldata scid,
        string calldata companyInfoField
    ) internal view returns (string memory value) {
        return Storage.SCRSlot().companiesInfo[scid][companyInfoField];
    }

    /**
     * @notice get the smart company id
     * @param founder the founder address
     * @return companyNumber the smart company id
     */
    function getSmartCompanyId(
        address founder
    ) internal view returns (string memory companyNumber) {
        return Storage.SCRSlot().founderCompanies[founder];
    }
}
