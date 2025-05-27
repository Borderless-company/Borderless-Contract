// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as SCRStorage} from "../storages/Storage.sol";

// lib
import {SCRLib} from "../lib/SCRLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {ArrayLib} from "../../../core/lib/ArrayLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";

// interfaces
import {ISCRErrors} from "../interfaces/ISCRErrors.sol";
import {ICompanyInfo} from "../interfaces/CompanyInfo/ICompanyInfo.sol";
import {IErrors} from "../../../core/utils/IErrors.sol";

/**
 * @title SmartCompany Registry v0.1.0
 * @notice This library contains functions for the CompanyInfo contract v0.1.0.
 */
contract CompanyInfo is ICompanyInfo {
    // ============================================== //
    //                  Modifiers                     //
    // ============================================== //

    modifier onlyFounder(string calldata scid) {
        require(
            SCRStorage.SCRSlot().companies[scid].founder == msg.sender,
            ISCRErrors.InvalidFounder(msg.sender)
        );
        _;
    }

    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function setCompanyInfo(
        string calldata scid,
        string calldata companyInfoField,
        string calldata value
    ) external override onlyFounder(scid) {
        SCRStorage.SCRSlot().companiesInfo[scid][companyInfoField] = value;
        emit UpdateCompanyInfo(msg.sender, scid, companyInfoField, value);
    }

    function addCompanyInfoFields(
        string calldata legalEntityCode,
        string calldata field
    ) external override {
        // check admin role
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        SCRStorage.SCRSlot().companyInfoFields[legalEntityCode].push(field);
        emit AddCompanyInfoField(msg.sender, legalEntityCode, field);
    }

    function updateCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex,
        string calldata field
    ) external override {
        // check admin role
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        uint256 length = SCRStorage
            .SCRSlot()
            .companyInfoFields[legalEntityCode]
            .length;
        require(fieldIndex < length, IErrors.InvalidLength(length, fieldIndex));
        SCRStorage.SCRSlot().companyInfoFields[legalEntityCode][
            fieldIndex
        ] = field;
        emit UpdateCompanyInfoField(
            msg.sender,
            fieldIndex,
            legalEntityCode,
            field
        );
    }

    function deleteCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex
    ) external override {
        // check admin role
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        string memory field = SCRStorage.SCRSlot().companyInfoFields[
            legalEntityCode
        ][fieldIndex];
        ArrayLib.removeAndCompact(
            SCRStorage.SCRSlot().companyInfoFields[legalEntityCode],
            fieldIndex
        );
        emit DeleteCompanyInfoField(
            msg.sender,
            fieldIndex,
            legalEntityCode,
            field
        );
    }

    // ============================================== //
    //           EXTERNAL READ FUNCTIONS              //
    // ============================================== //

    function getCompanyInfoFields(
        string calldata legalEntityCode
    ) external view override returns (string[] memory fields) {
        return SCRLib.getCompanyInfoFields(legalEntityCode);
    }

    function getCompanyInfo(
        string calldata scid
    )
        external
        view
        override
        returns (CompanyInfo memory companyInfo)
    {
        return SCRLib.getCompanyInfo(scid);
    }

    function getCompanyField(
        string calldata scid,
        string calldata companyInfoField
    ) external view override returns (string memory) {
        return SCRLib.getCompanyField(scid, companyInfoField);
    }
}
