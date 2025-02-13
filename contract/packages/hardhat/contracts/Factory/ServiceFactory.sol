// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {IServiceFactory} from "./interfaces/IServiceFactory.sol";
import {EventServiceFactory} from "./interfaces/EventServiceFactory.sol";
import {ErrorServiceFactory} from "./interfaces/ErrorServiceFactory.sol";

// Access Control
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

// Upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {BeaconUpgradeableBase} from "../upgradeable/BeaconUpgradeableBase.sol";

interface IServiceInitialize {
    function initialize(
        address _admin,
        address _serviceFactory,
        bytes memory _extraParams
    ) external;
}

contract ServiceFactory is
    Initializable,
    AccessControlEnumerableUpgradeable,
    BeaconUpgradeableBase,
    UUPSUpgradeable,
    IServiceFactory,
    EventServiceFactory,
    ErrorServiceFactory
{
    // ============================================== //
    //              State Variables                   //
    // ============================================== //
    address private _scr;
    uint256 private _serviceNumber;

    /// @dev Service implementation => Service type
    mapping(address serviceImplementation => ServiceType serviceType)
        private _serviceTypes;

    mapping(address founder => mapping(ServiceType serviceType => address service)) private _founderServices;

    // ============================================== //
    //                   Modifier                     //
    // ============================================== //

    modifier invalidAddress(address _serviceImplementation) {
        require(
            _serviceImplementation != address(0),
            InvalidAddress(_serviceImplementation)
        );
        _;
    }

    modifier onlySTR() {
        require(msg.sender == _scr, OnlySTR(msg.sender));
        _;
    }

    // ============================================== //
    //                   Initializer                  //
    // ============================================== //

    function initialize() external initializer  {
        __BeaconUpgradeableBase_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function setService(
        address _serviceImplementation,
        string calldata _serviceName,
        ServiceType _serviceType
    )
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        invalidAddress(_serviceImplementation)
    {
        _createBeaconProxy(_serviceImplementation, _serviceName);
        _serviceTypes[_serviceImplementation] = _serviceType;
        emit NewService(_serviceImplementation, _serviceName, _serviceType);
    }

    function updateServiceName(
        address _serviceImplementation,
        string calldata _serviceName,
        ServiceType _serviceType
    )
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        invalidAddress(_serviceImplementation)
    {
        (Beacon memory _beacon) = _updateBeaconName(
            _serviceImplementation,
            _serviceName
        );
        emit UpdateService(
            _serviceImplementation,
            _serviceName,
            _serviceType,
            _beacon.isOnline
        );
    }

    function changeServiceOnline(
        address _serviceImplementation,
        bool _isOnline
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _changeBeaconOnline(_serviceImplementation, _isOnline);
        emit UpdateService(
            _serviceImplementation,
            beacons[_serviceImplementation].name,
            _serviceTypes[_serviceImplementation],
            _isOnline
        );
    }

    function activate(
        address founder_,
        address _company,
        address _serviceImplementation,
        bytes memory _extraParams,
        ServiceType _serviceType
    ) external override onlySTR returns (address _service) {
        BeaconUpgradeableBase.Beacon memory _serviceInfo = beacons[
            _serviceImplementation
        ];

        // prepare init data
        bytes memory initData = abi.encodeWithSelector(
            IServiceInitialize(_serviceInfo.beacon).initialize.selector,
            founder_,
            _company,
            _extraParams
        );

        // Deploy new sc contract
        address _beacon = address(_serviceInfo.beacon);
        BeaconProxy proxy = new BeaconProxy(_beacon, initData);
        _service = address(proxy);
        require(
            _service != address(0),
            DoNotActivateService(msg.sender, _company, _serviceImplementation)
        );

        _addProxy(_serviceImplementation, _service);
        _founderServices[founder_][_serviceType] = _service;

        emit ActivateService(_serviceImplementation, _service);
        return _service;
    }

    function setSCR(address scr_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(scr_ != address(0), InvalidAddress(scr_));
        _scr = scr_;
    }

    // ============================================== //
    //             External Read Functions            //
    // ============================================== //

    function getService(
        address _serviceImplementation
    )
        external
        view
        override
        returns (
            string memory _serviceName,
            address _service,
            bool _isOnline,
            uint256 _proxyCount,
            uint256 _serviceType
        )
    {
        BeaconUpgradeableBase.Beacon memory _serviceInfo = beacons[
            _serviceImplementation
        ];
        (_serviceName, _service, _isOnline, _proxyCount, _serviceType) = (
            _serviceInfo.name,
            _serviceInfo.beacon,
            _serviceInfo.isOnline,
            _serviceInfo.proxyCount,
            uint256(_serviceTypes[_serviceImplementation])
        );
    }

    function getFounderServices(address founder_, ServiceType serviceType_) external view returns (address) {
        return _founderServices[founder_][serviceType_];
    }

    // ============================================== //
    //                     UUPS                       //
    // ============================================== //

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
