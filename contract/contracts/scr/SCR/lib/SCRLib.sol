// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";

// interfaces
import {ICompanyInfo} from "../interfaces/CompanyInfo/ICompanyInfo.sol";

library SCRLib {
    function getCompanyInfoFields(
        string calldata legalEntityCode
    ) internal view returns (string[] memory fields) {
        return Storage.SCRSlot().companyInfoFields[legalEntityCode];
    }

    function getCompanyInfo(
        string calldata scid
    ) internal view returns (ICompanyInfo.CompanyInfo memory companyInfo) {
        return Storage.SCRSlot().companies[scid];
    }

    function getCompanyField(
        string calldata scid,
        string calldata companyInfoField
    ) internal view returns (string memory value) {
        return Storage.SCRSlot().companiesInfo[scid][companyInfoField];
    }

    function getFounderCompanies(
        address founder
    ) internal view returns (string memory companyNumber) {
        return Storage.SCRSlot().founderCompanies[founder];
    }
}
