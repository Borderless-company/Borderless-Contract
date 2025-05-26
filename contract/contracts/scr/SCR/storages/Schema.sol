// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ICompanyInfo} from "../interfaces/CompanyInfo/ICompanyInfo.sol";

/**
 * @title Borderless SCR Schema v0.1.0
 */
library Schema {
    struct SCRLayout {
        /**
         * @dev legal entity code => country info field
         */
        mapping(string legalEntityCode => string[] countryInfoFields) companyInfoFields;
        /**
         * @dev smart company identifier => country info field => other info
         */
        mapping(string scid => mapping(string countryField => string value)) companiesInfo;
        /**
         * @dev smart company identifier => company info
         */
        mapping(string scid => ICompanyInfo.CompanyInfo companyInfo) companies;
        /**
         * @dev founder => smart company number
         */
        mapping(address founder => string scid) founderCompanies;
    }
}
