// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {BeaconUpgradeableBase} from "../../upgradeable/BeaconUpgradeableBase.sol";

/// @title feature interface for SCR (Smart Company Registry) contract
interface ISCR {
    // ============================================== //
    //                   Structs                      //
    // ============================================== //

    /**
     * @dev company info
     * @param companyAddress Company address
     * @param founder Founder address
     * @param establishmentDate Date of incorporation
     * @param jurisdiction Jurisdiction
     * @param companyType Entity type
     * @param otherInfo Other info
     * @param createAt Create at
     * @param updateAt Update at
     */
    struct CompanyInfo {
        string companyName;
        address companyAddress;
        address founder;
        string establishmentDate;
        string jurisdiction;
        string companyType;
        uint256 createAt;
        uint256 updateAt;
    }

    // ============================================== //
    //           External Write Functions             //
    // ============================================== //

    /**
     * @notice Create a new SmartCompany
     * @dev only executor can create a new SmartCompany
     * @param _scid The smart company identifier
     * @param _scImplementation The smart company implementation address
     * @param _legalEntityCode The legal entity code
     * @param _companyName The company name
     * @param _establishmentDate The date of incorporation
     * @param _jurisdiction The jurisdiction
     * @param _entityType The entity type
     * @param _scExtraParams The extra params. [sc extra params, ...sc extra params]
     * @param _otherInfo The other info
     * @param _scsAddresses The smart company service contract addresses
     * @param _scsExtraParams The extra params. [scs extra params, ...scs extra params]
     */
    function createSmartCompany(
        bytes calldata _scid,
        address _scImplementation,
        string calldata _legalEntityCode,
        string calldata _companyName,
        string calldata _establishmentDate,
        string calldata _jurisdiction,
        string calldata _entityType,
        bytes calldata _scExtraParams,
        string[] calldata _otherInfo,
        address[] calldata _scsAddresses,
        bytes[] calldata _scsExtraParams
    ) external returns (bool started_, address companyAddress_);

    /**
     * @notice Set the factory pool address
     * @dev only DEFAULT_ADMIN_ROLE can set the factory pool address
     * @param factoryPool_ The factory pool address
     */
    function setServiceFactory(address factoryPool_) external;

    /**
     * @notice Set the other info of the company
     * @dev only executor can set the other info
     * @param _scid The smart company number
     * @param _field The field of the other info
     * @param _value The value of the other info
     */
    function setCompanyOtherInfo(
        bytes calldata _scid,
        string calldata _field,
        string calldata _value
    ) external;

    /**
     * @notice Set the Smart Company contract
     * @dev only DEFAULT_ADMIN_ROLE can set the Smart Company contract
     * @param _implementation The Smart Company contract implementation address
     * @param _scName The Smart Company contract name
     */
    function setSCContract(
        address _implementation,
        string calldata _scName
    ) external;

    /**
     * @notice Update the Smart Company contract
     * @dev only DEFAULT_ADMIN_ROLE can update the Smart Company contract
     * @param _implementation The Smart Company contract implementation address
     * @param _scName The Smart Company contract name
     */
    function updateSCContract(
        address _implementation,
        string calldata _scName
    ) external;

    /**
     * @notice Add the company info field
     * @dev only DEFAULT_ADMIN_ROLE can add the company info field
     * @param _legalEntityCode The legal entity code
     * @param _field The field of the company info
     */
    function addCompanyInfoFields(
        string calldata _legalEntityCode,
        string calldata _field
    ) external;

    /**
     * @notice Update the company info field
     * @dev only DEFAULT_ADMIN_ROLE can update the company info field
     * @param _legalEntityCode The legal entity code
     * @param _fieldIndex The field index of the company info
     * @param _field The field of the company info
     */
    function updateCompanyInfoFields(
        string calldata _legalEntityCode,
        uint256 _fieldIndex,
        string calldata _field
    ) external;

    /**
     * @notice Delete the company info field
     * @dev only DEFAULT_ADMIN_ROLE can delete the company info field
     * @param _legalEntityCode The legal entity code
     * @param _fieldIndex The field index of the company info
     */
    function deleteCompanyInfoFields(
        string calldata _legalEntityCode,
        uint256 _fieldIndex
    ) external;

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    /**
     * @notice Get the company info fields
     * @param _legalEntityCode The legal entity code
     * @return fields_ The company info fields
     */
    function getCompanyInfoFields(
        string calldata _legalEntityCode
    ) external view returns (string[] memory fields_);

    /**
     * @notice Get the company info
     * @param _scid The company number
     * @return _info The company info
     */
    function getCompanyInfo(
        bytes calldata _scid
    ) external view returns (CompanyInfo memory _info);

    /**
     * @notice Get the company other info
     * @param _scid The smart company number
     * @param _field The field of the other info
     * @return _value The value of the other info
     */
    function getCompanyOtherInfo(
        bytes calldata _scid,
        string calldata _field
    ) external view returns (string memory _value);

    /**
     * @notice Get the founder's company index
     * @param founder_ The founder's address
     * @return companyNumber The founder's company number
     */
    function getFounderCompanies(
        address founder_
    ) external view returns (bytes memory companyNumber);

    /**
     * @notice Get the Smart Company info
     * @param _scImplementation The smart company implementation address
     * @return _info The Smart Company info
     */
    function getSCInfo(
        address _scImplementation
    ) external view returns (BeaconUpgradeableBase.Beacon memory _info);

    /**
     * @notice Get the factory pool address
     * @return factoryPool_ The factory pool address
     */
    function getServiceFactory() external view returns (address);
}
