// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ICompanyInfo} from "../../../scr/SCR/interfaces/CompanyInfo/ICompanyInfo.sol";
import {IBeaconUpgradeableBaseStructs} from "../../../scr/BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";
import {ServiceType} from "../../utils/ITypes.sol";

contract SCRProxy {
    constructor(address dictionary, bytes memory _data) {}

    // ERC165 functions
    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {}

    // Ownable functions
    function owner() public view returns (address) {}
    function renounceOwnership() public {}
    function transferOwnership(address newOwner) public {}

    // BorderlessAccessControl functions
    function initialize(address dictionary) external {}
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32) {}
    function FOUNDER_ROLE() external view returns (bytes32) {}
    function grantRole(bytes32 role, address account) external {}
    function revokeRole(bytes32 role, address account) external {}
    function renounceRole(bytes32 role, address callerConfirmation) external {}
    function getRoleAdmin(bytes32 role) external view returns (bytes32) {}
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool) {}

    // DictionaryBase functions
    function getImplementation(
        bytes4 selector
    ) external view returns (address) {}

    // Dictionary functions
    function setImplementation(
        bytes4 selector,
        address implementation
    ) external {}
    function bulkSetImplementation(
        bytes4[] memory selectors,
        address implementation
    ) external {}
    function upgradeFacade(address newFacade) external {}
    function setOnceInitialized(
        address account,
        address implementation
    ) external {}
    function getFacade() external view returns (address) {}

    // SCRBeaconUpgradeable functions
    function updateSCRBeaconName(
        address beacon,
        string calldata name
    ) external returns (IBeaconUpgradeableBaseStructs.Beacon memory) {}
    function changeSCRBeaconOnline(address beacon, bool isOnline) external {}
    function getSCRBeacon(
        address beacon
    ) external view returns (IBeaconUpgradeableBaseStructs.Beacon memory) {}
    function getSCRProxy(
        address proxy
    ) external view returns (IBeaconUpgradeableBaseStructs.Proxy memory) {}

    // ServiceFactoryBeaconUpgradeable functions
    function updateServiceFactoryBeaconName(
        address beacon,
        string calldata name
    ) external returns (IBeaconUpgradeableBaseStructs.Beacon memory) {}
    function changeServiceFactoryBeaconOnline(
        address beacon,
        bool isOnline
    ) external {}
    function getServiceFactoryBeacon(
        address beacon
    ) external view returns (IBeaconUpgradeableBaseStructs.Beacon memory) {}
    function getServiceFactoryProxy(
        address proxy
    ) external view returns (IBeaconUpgradeableBaseStructs.Proxy memory) {}

    // ServiceFactory functions
    function setService(
        address implementation,
        string calldata name,
        ServiceType serviceType
    ) external returns (address) {}
    function setLetsSaleBeacon(
        address letsBeacon,
        address letsSaleBeacon
    ) external {}
    function getServiceType(
        address beacon
    ) external view returns (ServiceType) {}
    function getFounderService(
        address founder,
        ServiceType serviceType
    ) external view returns (address) {}

    // CompanyInfo functions
    function setCompanyInfo(
        string calldata scid,
        string calldata companyInfoField,
        string calldata value
    ) external {}
    function addCompanyInfoFields(
        string calldata legalEntityCode,
        string calldata field
    ) external {}
    function updateCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex,
        string calldata field
    ) external {}
    function deleteCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex
    ) external {}
    function getCompanyInfoFields(
        string calldata legalEntityCode
    ) external view returns (string[] memory) {}
    function getCompanyInfo(
        string calldata scid
    ) external view returns (ICompanyInfo.CompanyInfo memory) {}
    function getCompanyField(
        string calldata scid,
        string calldata companyInfoField
    ) external view returns (string memory) {}

    // SCR functions
    function createSmartCompany(
        string calldata scid,
        address beacon,
        string calldata legalEntityCode,
        string calldata companyName,
        string calldata establishmentDate,
        string calldata jurisdiction,
        string calldata entityType,
        bytes calldata scDeployParam,
        string[] calldata companyInfo,
        address[] calldata scsBeaconProxy,
        bytes[] calldata scsDeployParams
    )
        external
        returns (
            address company,
            address[] memory services,
            ServiceType[] memory serviceTypes
        )
    {}
    function setSCContract(
        address scImplementation,
        string calldata scName
    ) external returns (address) {}
    function updateSCContract(
        address scBeacon,
        address newSCImplementation
    ) external {}
    function getFounderCompanies(
        address founder
    ) external view returns (string memory) {}
}
