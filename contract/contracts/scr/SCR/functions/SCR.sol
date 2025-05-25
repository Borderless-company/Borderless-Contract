// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../../core/Dictionary/Dictionary.sol";
import {CompanyInfo} from "./CompanyInfo.sol";
import {SCInitialize} from "../../../sc/SCT/functions/initialize/SCInitialize.sol";
import {Ownable} from "../../../sc/Ownable/functions/Ownable.sol";

// storages
import {Storage} from "../storages/Storage.sol";
import {Storage as ServiceFactoryStorage} from "../../Factory/storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../../core/BorderlessAccessControl/storages/Storage.sol";
import {Storage as BeaconUpgradeableBaseStorage} from "../../BeaconUpgradeableBase/storages/Storage.sol";

// lib
import {SCRLib} from "../lib/SCRLib.sol";
import {ServiceFactoryLib} from "../../Factory/lib/ServiceFactoryLib.sol";
import {LETSBaseInitializeLib} from "../../../sc/Services/LETS/libs/LETSBaseInitializeLib.sol";
import {BeaconUpgradeableBaseLib} from "../../BeaconUpgradeableBase/lib/BeaconUpgradeableBaseLib.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {ArrayLib} from "../../../core/lib/ArrayLib.sol";
import {Constants} from "../../../core/lib/Constants.sol";
import {DeployCoreContract} from "../../../core/lib/DeployCoreContract.sol";

// interfaces
import {ISCR} from "../interfaces/ISCR.sol";
import {ISCT} from "../../../sc/SCT/interfaces/ISCT.sol";
import {ServiceType} from "../../../core/utils/ITypes.sol";
import {ISCInitialize} from "../../../sc/SCT/interfaces/initialize/ISCInitialize.sol";
import {IInitialize} from "../../../core/Initialize/interfaces/IInitialize.sol";
import {IServiceInitialize} from "../../../core/utils/IServiceInitialize.sol";
import {ILETSBase} from "../../../sc/Services/LETS/interfaces/ILETSBase.sol";
import {ILETSSaleBase} from "../../../sc/Services/LETS/interfaces/ILETSSaleBase.sol";
import {IDictionary} from "../../../core/Dictionary/interfaces/IDictionary.sol";
import {IErrors} from "../../../core/utils/IErrors.sol";
import {IBeaconUpgradeableBaseStructs} from "../../BeaconUpgradeableBase/interfaces/IBeaconUpgradeableBaseStructs.sol";
import {console} from "hardhat/console.sol";
// openzeppelin

import {DynamicArrayLib} from "solady/src/utils/DynamicArrayLib.sol";


/**
 * @title SmartCompany Registry v0.1.0
 */
contract SCR is ISCR, CompanyInfo {
    using DynamicArrayLib for DynamicArrayLib.DynamicArray;

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
        returns (
            address company,
            address[] memory services,
            ServiceType[] memory serviceTypes
        )
    {
        // check founder role
        BorderlessAccessControlLib.onlyRole(Constants.FOUNDER_ROLE, msg.sender);

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

        // check company info
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

        (company, services, serviceTypes) = _createSmartCompany(
            scid,
            companyInfo_,
            beacon,
            scDeployParam,
            scsBeaconProxy,
            scsDeployParams
        );
    }

    function setSCContract(
        address scImplementation,
        string calldata scName
    ) external override returns (address beacon) {
        // check admin role
        BorderlessAccessControlLib.onlyRole(
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
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );

        BeaconUpgradeableBaseLib.upgradeBeacon(
            BeaconUpgradeableBaseStorage.SCRBeaconProxySlot(),
            scBeacon,
            newSCImplementation
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
    )
        private
        returns (
            address company,
            address[] memory services,
            ServiceType[] memory serviceTypes
        )
    {
        IBeaconUpgradeableBaseStructs.Beacon
            memory beaconInfo = BeaconUpgradeableBaseStorage
                .SCRBeaconProxySlot()
                .beacons[beacon];

        // check if the SmartCompany is online
        require(beaconInfo.isOnline, SmartCompanyNotOnline(beacon));

        // Deploy dictionary & initialize & borderlessAccessControl contract
        address dictionary = DeployCoreContract.deployDictionary(address(this));
        address borderlessAccessControl = DeployCoreContract
            .deployBorderlessAccessControl();
        address sc = BeaconUpgradeableBaseLib.createProxy(
            BeaconUpgradeableBaseStorage.SCRBeaconProxySlot(),
            beacon,
            ""
        );
        address scInitialize = DeployCoreContract.deploySCInitialize();

        // Deploy proxy contract
        company = DeployCoreContract.deployProxy(dictionary, "");

        require(
            company != address(0) &&
                borderlessAccessControl != address(0) &&
                dictionary != address(0),
            FailedDeploySmartCompany(scid)
        );

        IDictionary(dictionary).setOnceInitialized(
            borderlessAccessControl,
            borderlessAccessControl
        );
        // IDictionary(dictionary).setOnceInitialized(scInitialize, sc);
        IDictionary(dictionary).setImplementation(
            bytes4(keccak256("initialize(address,address,address,address)")),
            scInitialize
        );


        IInitialize(borderlessAccessControl).initialize(dictionary);
        ISCInitialize(company).initialize(
            dictionary,
            sc,
            companyInfo.founder,
            address(this)
        );

        console.log("done sc initialize");

        // register company address
        Storage.SCRSlot().companies[scid].companyAddress = company;
        // register founder to company number
        Storage.SCRSlot().founderCompanies[companyInfo.founder] = scid;

        (services, serviceTypes) = _setupService(
            companyInfo.founder,
            company,
            dictionary,
            scsBeaconProxy,
            scsDeployParams
        );

        Ownable(dictionary).transferOwnership(companyInfo.founder);

        emit DeploySmartCompany(
            companyInfo.founder,
            company,
            scid,
            services,
            serviceTypes
        );
    }

    /**
     * @dev Setup service
     * @param founder Founder account
     * @param company SmartCompany account to setup service
     * @param scsAddresses Smart Company Service Beacon Proxy addresses
     * @return services Deployed services addresses
     * @return serviceTypes Deployed services types
     */
    function _setupService(
        address founder,
        address company,
        address dictionary,
        address[] calldata scsAddresses,
        bytes[] calldata scsDeployParams
    )
        internal
        returns (address[] memory services, ServiceType[] memory serviceTypes)
    {
        DynamicArrayLib.DynamicArray memory tmpServices;
        DynamicArrayLib.DynamicArray memory tmpTypes;
        uint256 serviceCount;
        for (uint256 index = 0; index < scsAddresses.length; index++) {
            (address service, ServiceType serviceType) = _deployService(
                founder,
                company,
                scsAddresses[index],
                dictionary
            );

            if (
                serviceType == ServiceType.LETS_EXE ||
                serviceType == ServiceType.LETS_NON_EXE
            ) {
                // Deploy lets dictionary & initialize & borderlessAccessControl contract
                address letsDictionary = DeployCoreContract.deployDictionary(
                    address(this)
                );

                // Deploy proxy contract
                address letsProxy = DeployCoreContract.deployProxy(
                    letsDictionary,
                    ""
                );
                address letsOwnable = DeployCoreContract.deployOwnable();
                IDictionary(letsDictionary).setOnceInitialized(letsProxy, service);
                IDictionary(letsDictionary).setOnceInitialized(letsOwnable, letsOwnable);
                IDictionary(letsDictionary).setImplementation(
                    bytes4(keccak256("initialize(address,address,address,bytes)")),
                    service
                );
                // initialize lets
                ILETSBase(letsProxy).initialize(
                    letsDictionary,
                    service,
                    company,
                    scsDeployParams[index]
                );
                Ownable(letsOwnable).initialize(founder);
                ServiceFactoryStorage.ServiceFactorySlot().founderServices[founder][
                    serviceType
                ] = letsProxy;
                service = letsProxy;
                console.log("letsProxy: ", letsProxy);
                console.logUint(uint256(serviceType));
                address letsSaleBeacon = ServiceFactoryStorage
                    .ServiceFactorySlot()
                    .letsSaleBeacons[scsAddresses[index]];
                (
                    address letsSaleAddress,
                    ServiceType letsSaleType
                ) = _deployService(
                        founder,
                        company,
                        letsSaleBeacon,
                        letsDictionary
                    );
                tmpServices = tmpServices.p(letsSaleAddress);
                tmpTypes = tmpTypes.p(uint256(letsSaleType));
                serviceCount++;

                Ownable(letsDictionary).transferOwnership(founder);
            }

            tmpServices = tmpServices.p(service);
            tmpTypes = tmpTypes.p(uint256(serviceType));
            serviceCount++;

        }

        services = DynamicArrayLib.asAddressArray(tmpServices.data);
        uint256[] memory rawTypes = tmpTypes.data;
        serviceTypes = new ServiceType[](rawTypes.length);
        for (uint256 j = 0; j < rawTypes.length; ++j) {
            serviceTypes[j] = ServiceType(rawTypes[j]);
        }

        ISCT(company).registerService(serviceTypes, services);
    }

    function _deployService(
        address founder,
        address company,
        address beacon,
        address dictionary
    ) internal returns (address service, ServiceType serviceType) {
        (service, serviceType) = ServiceFactoryLib.activate(
            founder,
            company,
            beacon
        );
        require(
            service != address(0),
            NotActivateService(msg.sender, company, beacon)
        );

        if (
            serviceType != ServiceType.LETS_EXE &&
            serviceType != ServiceType.LETS_NON_EXE
        ) {
            IDictionary(dictionary).setOnceInitialized(service, service);
            IServiceInitialize(service).initialize(dictionary);
        }
    }

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    function getSmartCompany(
        address founder
    ) external view returns (string memory) {
        return SCRLib.getSmartCompany(founder);
    }
}
