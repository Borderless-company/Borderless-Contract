// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";
import {Storage as ServiceFactoryStorage} from "../../Factory/storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../BorderlessAccessControl/storages/Storage.sol";
import {Storage as BeaconUpgradeableBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {SCRLib} from "../lib/SCRLib.sol";
import {ServiceFactoryLib} from "../../Factory/lib/ServiceFactoryLib.sol";
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/lib/BeaconUpgradeableBaseLib.sol";
import {AccessControlLib} from "../../BorderlessAccessControl/lib/AccessControlLib.sol";
import {ArrayLib} from "../../lib/ArrayLib.sol";
import {Constants} from "../../lib/Constants.sol";

// interfaces
import {ISCR} from "../interfaces/ISCR.sol";
import {IServiceFactory} from "../../Factory/interfaces/IServiceFactory.sol";
import {ServiceType, ContractType} from "../../utils/ITypes.sol";
import {ISCTInitialize} from "../../utils/ISCTInitialize.sol";
import {IErrors} from "../../utils/IErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../../BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {console} from "hardhat/console.sol";
/**
 * @title SmartCompany Registry v0.1.0
 */
contract SCR is ISCR, Initializable {
    // ============================================== //
    //                  Modifiers                     //
    // ============================================== //

    modifier onlyOnceEstablish(address founder, string calldata scid) {
        require(
            bytes(Storage.SCRSlot().founderCompanies[founder]).length == 0,
            AlreadyEstablish(founder, scid)
        );
        _;
    }

    modifier onlyFounder(string calldata scid) {
        require(
            Storage.SCRSlot().companies[scid].founder == msg.sender,
            InvalidFounder(msg.sender)
        );
        _;
    }

    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ============================================== //
    //                   Initializer                  //
    // ============================================== //

    /**
     * @notice Initialize the SCR
     */
    function initialize() external initializer {}

    // ============================================== //
    //           External Write Functions             //
    // ============================================== //

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
        override
        onlyOnceEstablish(msg.sender, scid)
        returns (address company, address[] memory services)
    {
        // check founder role
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.FOUNDER_ROLE,
            msg.sender
        );

        // check params
        require(
            bytes(scid).length != 0 &&
                bytes(establishmentDate).length != 0 &&
                bytes(jurisdiction).length != 0 &&
                bytes(entityType).length != 0,
            InvalidCompanyInfo()
        );

        // check scid is unique
        require(
            SCRLib.getCompanyInfo(scid).founder == address(0),
            AlreadyRegisteredScid(scid)
        );

        // check other info
        require(
            companyInfo.length ==
                SCRLib.getCompanyInfoFields(legalEntityCode).length,
            InvalidCompanyInfoLength(
                SCRLib.getCompanyInfoFields(legalEntityCode).length,
                companyInfo.length
            )
        );

        CompanyInfo memory companyInfo_;
        companyInfo_.companyName = companyName;
        companyInfo_.founder = msg.sender;
        companyInfo_.establishmentDate = establishmentDate;
        companyInfo_.jurisdiction = jurisdiction;
        companyInfo_.entityType = entityType;
        companyInfo_.createAt = block.timestamp;
        companyInfo_.updateAt = block.timestamp;

        string[] memory fields = SCRLib.getCompanyInfoFields(legalEntityCode);

        for (uint256 i = 0; i < companyInfo.length; i++) {
            Storage.SCRSlot().companiesInfo[scid][fields[i]] = companyInfo[i];
        }

        console.log("call createSmartCompany");
        (company, services) = _createSmartCompany(
            scid,
            companyInfo_,
            beacon,
            scDeployParam,
            scsBeaconProxy,
            scsDeployParams
        );
    }

    function setCompanyInfo(
        string calldata scid,
        string calldata companyInfoField,
        string calldata value
    ) external override onlyFounder(scid) {
        Storage.SCRSlot().companiesInfo[scid][companyInfoField] = value;
        emit UpdateCompanyInfo(msg.sender, scid, companyInfoField, value);
    }

    function setSCContract(
        address scImplementation,
        string calldata scName
    ) external override returns (address beacon) {
        // check admin role
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        beacon = BeaconUpgradeableBaseLib.createBeaconProxy(
            BeaconUpgradeableBaseStorage.SCRBeaconProxySlot(),
            scImplementation,
            scName
        );
    }

    function updateSCContract(
        address scBeacon,
        address newSCImplementation
    ) external override {
        // check admin role
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        BeaconUpgradeableBaseLib.upgradeBeacon(
            BeaconUpgradeableBaseStorage.SCRBeaconProxySlot(),
            scBeacon,
            newSCImplementation
        );
    }

    function addCompanyInfoFields(
        string calldata legalEntityCode,
        string calldata field
    ) external override {
        // check admin role
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        Storage.SCRSlot().companyInfoFields[legalEntityCode].push(field);
        emit AddCompanyInfoField(msg.sender, legalEntityCode, field);
    }

    function updateCompanyInfoFields(
        string calldata legalEntityCode,
        uint256 fieldIndex,
        string calldata field
    ) external override {
        // check admin role
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        uint256 length = Storage
            .SCRSlot()
            .companyInfoFields[legalEntityCode]
            .length;
        require(fieldIndex < length, IErrors.InvalidLength(length, fieldIndex));
        Storage.SCRSlot().companyInfoFields[legalEntityCode][
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
        AccessControlLib.onlyRole(
            AccessControlStorage.AccessControlSlot(),
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        string memory field = Storage.SCRSlot().companyInfoFields[
            legalEntityCode
        ][fieldIndex];
        ArrayLib.removeAndCompact(
            Storage.SCRSlot().companyInfoFields[legalEntityCode],
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
    //            Internal Write Functions            //
    // ============================================== //

    /**
     * @dev Create a new SmartCompany
     * @param scid New SmartCompany information
     * @param companyInfo New SmartCompany information
     * @param beacon SmartCompany beacon proxy address
     * @param scDeployParam SC extra params
     * @param scsBeaconProxy SCs addresses
     * @param scsDeployParams SCs extra params
     * @return company New SmartCompany address
     * @return services Deployed services addresses
     */
    function _createSmartCompany(
        string calldata scid,
        CompanyInfo memory companyInfo,
        address beacon,
        bytes calldata scDeployParam,
        address[] calldata scsBeaconProxy,
        bytes[] calldata scsDeployParams
    ) private returns (address company, address[] memory services) {
        IBeaconUpgradeableBaseStructs.Beacon
            memory beaconInfo = BeaconUpgradeableBaseStorage
                .SCRBeaconProxySlot()
                .beacons[beacon];

        console.log("beaconInfo.isOnline", beaconInfo.isOnline);
        console.log("beaconInfo.implementation", beaconInfo.implementation);
        console.log("beaconInfo.name", beaconInfo.name);
        console.log("beaconInfo.proxyCount", beaconInfo.proxyCount);

        // check if the SmartCompany is online
        require(beaconInfo.isOnline, SmartCompanyNotOnline(beacon));

        // prepare init data
        bytes memory initData = abi.encodeWithSelector(
            ISCTInitialize(beaconInfo.implementation).initialize.selector,
            companyInfo.founder,
            address(this),
            scDeployParam
        );

        console.log("prepare init data");

        // Deploy new sc contract
        company = BeaconUpgradeableBaseLib.createProxy(
            BeaconUpgradeableBaseStorage.SCRBeaconProxySlot(),
            beacon,
            initData
        );
        console.log("createProxy");
        require(company != address(0), FailedDeploySmartCompany(scid));
        console.log("company", company);

        // register company address
        Storage.SCRSlot().companies[scid].companyAddress = company;
        // register founder to company number
        Storage.SCRSlot().founderCompanies[companyInfo.founder] = scid;

        services = _setupService(
            companyInfo.founder,
            company,
            scsBeaconProxy,
            scsDeployParams
        );

        emit DeploySmartCompany(companyInfo.founder, company, scid);
    }

    /**
     * @dev Setup service
     * @param founder Founder account
     * @param company SmartCompany account to setup service
     * @param scsAddresses Smart Company Service Beacon Proxy addresses
     * @param scsDeployParams Smart Company Service deployment params
     * @return services Deployed services addresses
     */
    function _setupService(
        address founder,
        address company,
        address[] calldata scsAddresses,
        bytes[] calldata scsDeployParams
    ) internal returns (address[] memory services) {
        ServiceType[] memory serviceTypes = new ServiceType[](
            scsAddresses.length
        );
        services = new address[](scsAddresses.length);

        for (uint256 index = 0; index < scsAddresses.length; index++) {
            console.log("index", index);

            // deploy service contract
            (
                address activatedAddress,
                ServiceType serviceType
            ) = ServiceFactoryLib.activate(
                    founder,
                    company,
                    scsAddresses[index],
                    scsDeployParams[index]
                );
            console.log("activatedAddress", activatedAddress);
            require(
                activatedAddress != address(0),
                NotActivateService(msg.sender, company, scsAddresses[index])
            );
            console.log("save service contract address");
            // save service contract address
            serviceTypes[index] = serviceType;
            services[index] = activatedAddress;
        }

        console.log("done setup service");

        // initialize SC contract
        ISCTInitialize(company).registerService(serviceTypes, services);
        console.log("registerService", company);
    }

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    function getCompanyInfoFields(
        string calldata legalEntityCode
    ) external view returns (string[] memory fields) {
        return SCRLib.getCompanyInfoFields(legalEntityCode);
    }

    function getCompanyInfo(
        string calldata scid
    ) external view returns (ISCR.CompanyInfo memory companyInfo) {
        return SCRLib.getCompanyInfo(scid);
    }

    function getCompanyField(
        string calldata scid,
        string calldata companyInfoField
    ) external view returns (string memory) {
        return SCRLib.getCompanyField(scid, companyInfoField);
    }

    function getFounderCompanies(
        address founder
    ) external view returns (string memory) {
        return SCRLib.getFounderCompanies(founder);
    }
}
