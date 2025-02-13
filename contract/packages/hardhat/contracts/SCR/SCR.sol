// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

// interfaces
import {ISCR} from "./interfaces/ISCR.sol";
import {EventSCR} from "./interfaces/EventSCR.sol";
import {ErrorSCR} from "./interfaces/ErrorSCR.sol";
import {IServiceFactory} from "../Factory/interfaces/IServiceFactory.sol";

// access control
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

// upgradeable
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {BeaconUpgradeableBase} from "../upgradeable/BeaconUpgradeableBase.sol";

// library
import {DynamicArrayLib} from "solady/utils/DynamicArrayLib.sol";
import {ArrayLib} from "../lib/ArrayLib.sol";

interface ISCTInitialize {
    function initialize(address admin_, address register_, bytes calldata) external;

    function initialService(
        address _founder,
        address[] calldata _services
    ) external returns (bool completed_);
}

interface IVoteInitialize {
    function initialize(address nftContract_) external;
}

/// @title SmartCompany Registry
contract SCR is
    ISCR,
    EventSCR,
    ErrorSCR,
    AccessControlEnumerableUpgradeable,
    BeaconUpgradeableBase,
    UUPSUpgradeable
{
    using DynamicArrayLib for uint256[];
    // ============================================== //
    //                   Storage                      //
    // ============================================== //
    bytes32 public constant FOUNDER_ROLE = keccak256("FOUNDER_ROLE");

    IServiceFactory private _serviceFactory;
    uint256 private _scContractCount;
    address public voteContract;

    /// @dev legal entity code => country info field
    mapping(string legalEntityCode => string[] countryInfoFields)
        private _companyInfoFields;
    /// @dev smart company identifier => company info
    mapping(bytes _scid => CompanyInfo companyInfo) private _companies;
    /// @dev smart company identifier => country info field => other info
    mapping(bytes _scid => mapping(string countryField => string value))
        private _companiesOtherInfo;
    /// @dev founder => smart company number
    mapping(address founder => bytes _scid) private _founderCompanies;

    mapping(address founder => address _vote) public _votes;

    // ============================================== //
    //                  Modifiers                     //
    // ============================================== //

    modifier onlyOnceEstablish(address founder_) {
        require(
            keccak256(_founderCompanies[founder_]) == keccak256(bytes("")),
            AlreadyEstablish(founder_)
        );
        _;
    }

    modifier onlyFounder(bytes calldata _scid) {
        require(_companies[_scid].founder == msg.sender, InvalidFounder(msg.sender));
        _;
    }

    modifier checkAddressZero(address _address) {
        require(_address != address(0), InvalidParam());
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

    /// @notice Initialize the SCR
    /// @param serviceFactory_ The factory pool address
    function initialize(address serviceFactory_, address voteContract_) external initializer {
        __BeaconUpgradeableBase_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _serviceFactory = IServiceFactory(serviceFactory_);
        _createBeaconProxy(voteContract_, "Vote");
        voteContract = voteContract_;
    }

    // ============================================== //
    //           External Write Functions             //
    // ============================================== //

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
    )
        external
        override
        onlyRole(FOUNDER_ROLE)
        onlyOnceEstablish(msg.sender)
        returns (bool started_, address companyAddress_, address[] memory services_)
    {
        // check params
        require(
            _scid.length != 0 &&
                bytes(_establishmentDate).length != 0 &&
                bytes(_jurisdiction).length != 0 &&
                bytes(_entityType).length != 0,
            InvalidCompanyInfo(msg.sender)
        );
        // check other info
        require(
            _otherInfo.length == _companyInfoFields[_legalEntityCode].length,
            InvalidOtherInfo(msg.sender)
        );

        CompanyInfo memory _info;
        _info.companyName = _companyName;
        _info.founder = msg.sender;
        _info.establishmentDate = _establishmentDate;
        _info.jurisdiction = _jurisdiction;
        _info.companyType = _entityType;
        _info.createAt = block.timestamp;
        _info.updateAt = block.timestamp;

        string[] memory _fields = _companyInfoFields[_legalEntityCode];

        for (uint256 i = 0; i < _otherInfo.length; i++) {
            _companiesOtherInfo[_scid][_fields[i]] = _otherInfo[i];
        }

        (started_, companyAddress_, services_) = _createSmartCompany(
            _scid,
            _info,
            _scImplementation,
            _scExtraParams,
            _scsAddresses,
            _scsExtraParams
        );
    }

    function setServiceFactory(
        address serviceFactory_
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) checkAddressZero(serviceFactory_) {
        _serviceFactory = IServiceFactory(serviceFactory_);

        emit SetFactoryPool(msg.sender, serviceFactory_);
    }

    function setCompanyOtherInfo(
        bytes calldata _scid,
        string calldata _field,
        string calldata _value
    ) external override onlyRole(FOUNDER_ROLE) {
        CompanyInfo memory _info = _companies[_scid];
        require(_info.founder == msg.sender, InvalidParam());
        _companiesOtherInfo[_scid][_field] = _value;
    }

    function setSCContract(
        address _scImplementation,
        string calldata _scName
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _createBeaconProxy(_scImplementation, _scName);
    }

    function updateSCContract(
        address _scImplementation,
        string calldata _scName
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _updateBeaconName(_scImplementation, _scName);
    }

    function addCompanyInfoFields(
        string calldata _legalEntityCode,
        string calldata _field
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _companyInfoFields[_legalEntityCode].push(_field);
        emit UpdateCompanyInfoField(
            msg.sender,
            _companyInfoFields[_legalEntityCode].length - 1,
            _legalEntityCode,
            _field
        );
    }

    function updateCompanyInfoFields(
        string calldata _legalEntityCode,
        uint256 _fieldIndex,
        string calldata _field
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _fieldIndex < _companyInfoFields[_legalEntityCode].length,
            InvalidParam()
        );
        _companyInfoFields[_legalEntityCode][_fieldIndex] = _field;
        emit UpdateCompanyInfoField(
            msg.sender,
            _fieldIndex,
            _legalEntityCode,
            _field
        );
    }

    function deleteCompanyInfoFields(
        string calldata _legalEntityCode,
        uint256 _fieldIndex
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        ArrayLib.removeAndCompact(
            _companyInfoFields[_legalEntityCode],
            _fieldIndex
        );
        emit DeleteCompanyInfoField(msg.sender, _fieldIndex, _legalEntityCode);
    }
    // ============================================== //
    //            Internal Write Functions            //
    // ============================================== //

    /**
     * @dev Create a new SmartCompany
     * @param _scid New SmartCompany information
     * @param _info New SmartCompany information
     * @param _scImplementation SmartCompany implementation address
     * @param _scExtraParams SC extra params
     * @param _scsAddresses SCs addresses
     * @param _scsExtraParams SCs extra params
     * @return started_ Whether the new SmartCompany is created
     * @return companyAddress_ New SmartCompany address
     * @return services_ Deployed services addresses
     */
    function _createSmartCompany(
        bytes calldata _scid,
        CompanyInfo memory _info,
        address _scImplementation,
        bytes calldata _scExtraParams,
        address[] calldata _scsAddresses,
        bytes[] calldata _scsExtraParams
    ) private returns (bool started_, address companyAddress_, address[] memory services_) {
        bool _completed;
        uint256 _index;

        BeaconUpgradeableBase.Beacon memory _scInfo = beacons[_scImplementation];

        // prepare init data
        bytes memory initData = abi.encodeWithSelector(
            ISCTInitialize(_scInfo.beacon).initialize.selector,
            _info.founder,
            address(this),
            _scExtraParams
        );

        // Deploy new sc contract
        address _beacon = address(_scInfo.beacon);
        BeaconProxy proxy = new BeaconProxy(_beacon, initData);
        address _company = address(proxy);
        require(_company != address(0), DoNotCreateSmartCompany(msg.sender));

        _info.companyAddress = _company;
        _companies[_scid] = _info;
        _founderCompanies[_info.founder] = _scid;
        _addProxy(_scImplementation, address(proxy));

        (_completed, services_) = _setupService(
            _info.founder,
            _company,
            _scsAddresses,
            _scsExtraParams
        );

        if (_completed) emit NewSmartCompany(_info.founder, _company, _index, _scid);

        (started_, companyAddress_) = (_completed, _info.companyAddress);
    }

    /**
     * @dev Setup service
     * @param _founder Founder account
     * @param _company SmartCompany account to setup service
     * @param _scsAddresses SCs addresses
     * @param _scsExtraParams SCs extra params
     * @return completed_ Whether the service setup is completed
     * @return services_ Deployed services addresses
     */
    function _setupService(
        address _founder,
        address _company,
        address[] calldata _scsAddresses,
        bytes[] calldata _scsExtraParams
    ) internal returns (bool completed_, address[] memory services_) {
        // deploy services address
        services_ = new address[](_scsAddresses.length);
        bool _online;
        uint256 _scsType;
        // デプロイ済みのServiceコントラクトのタイプの配列（同じタイプのコントラクトはデプロイできない）
        uint256[] memory _deployedScsTypes = new uint256[](_scsAddresses.length);

        for (uint256 _index = 0; _index < _scsAddresses.length; _index++) {
            // デプロイするServiceコントラクトの情報を取得
            (,, _online, , _scsType) = _serviceFactory.getService(
                _scsAddresses[_index]
            );

            // 既に同じタイプのServiceコントラクトがデプロイ済みの場合はエラー
            require(
                !_deployedScsTypes.contains(_scsType),
                AlreadyDeployedService(
                    msg.sender,
                    _scsAddresses[_index],
                    _scsType
                )
            );

            // Serviceコントラクトが有効でない場合はエラー
            require(_online, ServiceNotOnline(msg.sender, _scsAddresses[_index]));

            // Serviceコントラクトをデプロイ
            address activatedAddress = IServiceFactory(_serviceFactory).activate(
                _founder,
                _company,
                _scsAddresses[_index],
                _scsExtraParams[_index],
                IServiceFactory.ServiceType(_scsType)
            );
            // Serviceコントラクトのアドレスを保存
            services_[_index] = activatedAddress;
            // デプロイ済みのServiceコントラクトのタイプを設定
            _deployedScsTypes[_index] = _scsType;

            // prepare init data
            BeaconUpgradeableBase.Beacon memory _voteInfo = beacons[voteContract];
            bytes memory initData = abi.encodeWithSelector(
                IVoteInitialize(_voteInfo.beacon).initialize.selector,
                activatedAddress
            );

            // Deploy vote contract
            if (_scsType == uint256(IServiceFactory.ServiceType.LETS_EXE)) {
                BeaconProxy proxy = new BeaconProxy(_voteInfo.beacon, initData);
                address _vote = address(proxy);
                _votes[_founder] = _vote;
            }
        }

        // SCコントラクトを初期化
        completed_ = ISCTInitialize(_company).initialService(
            _founder,
            services_
        );
    }

    // ============================================== //
    //           External Read Functions              //
    // ============================================== //

    function getCompanyInfoFields(
        string calldata _legalEntityCode
    ) external view returns (string[] memory fields_) {
        return _companyInfoFields[_legalEntityCode];
    }

    function getCompanyInfo(
        bytes calldata _scid
    ) external view override returns (CompanyInfo memory _info) {
        return _companies[_scid];
    }

    function getCompanyOtherInfo(
        bytes calldata _scid,
        string calldata _field
    ) external view returns (string memory _value) {
        return _companiesOtherInfo[_scid][_field];
    }

    function getFounderCompanies(
        address founder_
    ) external view returns (bytes memory companyNumber) {
        return _founderCompanies[founder_];
    }

    function getSCInfo(
        address _scImplementation
    ) external view returns (BeaconUpgradeableBase.Beacon memory _info) {
        return beacons[_scImplementation];
    }

    function getServiceFactory() external view returns (address) {
        return address(_serviceFactory);
    }

    function getVoteContract(address founder_) external view returns (address) {
        return _votes[founder_];
    }

    // ============================================== //
    //                     UUPS                       //
    // ============================================== //

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
