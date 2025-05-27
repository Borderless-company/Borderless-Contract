// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ICompanyInfoFunctions} from "../interfaces/CompanyInfo/ICompanyInfoFunctions.sol";
import {ICompanyInfoStructs} from "../interfaces/CompanyInfo/ICompanyInfoStructs.sol";

/**
 * @title CompanyInfoProxy
 * @notice CompanyInfoProxy is a proxy contract for the CompanyInfo contract.
 */
contract CompanyInfoProxy is ICompanyInfoFunctions {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function setCompanyInfo(
        string calldata scid,
        string calldata field,
        string calldata value
    ) external override {}

    function addCompanyInfoFields(
        string calldata legalEntityCode,
        string calldata field
    ) external override {}

    function updateCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex,
        string calldata field
    ) external override {}

    function deleteCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex
    ) external override {}

    // ============================================== //
    //           EXTERNAL READ FUNCTIONS              //
    // ============================================== //

    function getCompanyInfoFields(
        string calldata legalEntityCode
    ) external view override returns (string[] memory fields) {}

    function getCompanyInfo(
        string calldata scid
    )
        external
        view
        override
        returns (ICompanyInfoStructs.CompanyInfo memory companyInfo)
    {}

    function getCompanyField(
        string calldata scid,
        string calldata companyInfoField
    ) external view override returns (string memory) {}
}
