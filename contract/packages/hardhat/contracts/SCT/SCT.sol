// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

// interfaces
import {ISCT} from "./interfaces/ISCT.sol";
import {EventSCT} from "./interfaces/EventSCT.sol";
import {ErrorSCT} from "./interfaces/ErrorSCT.sol";
import {ILETSBase} from "../Services/LETS/interfaces/ILETSBase.sol";

// access control
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title SCT (Smart Company Template) contract
contract SCT is
    ISCT,
    EventSCT,
    ErrorSCT,
    Initializable,
    AccessControlEnumerableUpgradeable
{
    // ============================================== //
    //                  Storage                       //
    // ============================================== //

    // 代表社員(DEFAULT_ADMIN_ROLE)
    // 財務担当者
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    // 署名担当者
    bytes32 public constant SIGNATURE_ROLE = keccak256("SIGNATURE_ROLE");
    // 経理担当者
    bytes32 public constant ACCOUNTING_ROLE = keccak256("ACCOUNTING_ROLE");
    // トークン発行管理者
    bytes32 public constant TOKEN_MINT_ROLE = keccak256("TOKEN_MINT_ROLE");

    address private _register;
    address private _governance;
    address public letsExe;
    address public letsNonExe;
    bool private _initialServiceCompleted;
    bool private _initialRoleCompleted;

    /// @dev service index => service address
    mapping(uint256 index_ => address service_) private _serviceContracts;

    /// @dev account => investment amount
    mapping(address account_ => uint256 investmentAmount_)
        private _investmentAmount;

    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    modifier onlyRegister() {
        require(msg.sender == _register, InvalidRegister(msg.sender));
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == _governance, NotGovernanceContract(msg.sender));
        _;
    }

    modifier onlyInitialServiceCompleted() {
        require(!_initialServiceCompleted, InitialServiceCompleted());
        _;
    }

    modifier onlyInitialRoleCompleted() {
        require(!_initialRoleCompleted, InitialRoleCompleted());
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

    /// @notice Initialize the SCT
    /// @param _founder The founder address
    /// @param register_ The register address
    function __SCT_initialize(
        address _founder,
        address register_
    ) internal initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _founder);
        _register = register_;
    }

    // ============================================== //
    //            External Write Functions            //
    // ============================================== //

    function initialService(
        address _founder,
        address[] calldata _services
    ) external override onlyRegister returns (bool completed_) {
        for (uint256 index = 0; index < _services.length; index++) {
            address activatedAddress = _services[index];
            require(
                activatedAddress != address(0),
                InvalidAddress(activatedAddress)
            );
            _serviceContracts[index] = activatedAddress;
        }

        completed_ = _initialService(_services);
    }

    function initialMintExecuteMember(
        address[] calldata _executeMembers
    ) external onlyInitialServiceCompleted onlyRole(DEFAULT_ADMIN_ROLE) {
        // mint execute members token
        for (uint256 index = 0; index < _executeMembers.length; index++) {
            ILETSBase(letsExe).mint(_executeMembers[index], 2 + index);
        }

        _initialRoleCompleted = true;
    }

    function initialRole(
        address _signatureMember,
        address _treasuryMember,
        address _accountingMember
    ) external onlyInitialRoleCompleted onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(SIGNATURE_ROLE, _signatureMember);
        _grantRole(TREASURY_ROLE, _treasuryMember);
        _grantRole(ACCOUNTING_ROLE, _accountingMember);
        _initialRoleCompleted = true;
    }

    // ============================================== //
    //             Internal Write Functions           //
    // ============================================== //

    function _initialService(
        address[] calldata _services
    ) internal returns (bool completed_) {
        address[] memory activeServices = new address[](_services.length);
        for (uint256 _index = 0; _index < _services.length; _index++) {
            address activatedAddress = _services[_index];
            _serviceContracts[_index] = activatedAddress;
            activeServices[_index] = activatedAddress;
        }

        emit InitialService(address(this), activeServices);
        completed_ = true;
    }

    // ============================================== //
    //            External Read Functions             //
    // ============================================== //

    /// @notice Get the service address
    /// @param index_ The service index
    /// @return service_ The service address
    function getService(
        uint256 index_
    ) external view override returns (address service_) {
        service_ = _serviceContracts[index_];
        require(service_ != address(0), InvalidIndex(index_));
    }

    /// @notice Get the investment amount
    /// @param account_ The account address
    /// @return investmentAmount_ The investment amount
    function getInvestmentAmount(
        address account_
    ) external view override returns (uint256 investmentAmount_) {
        investmentAmount_ = _investmentAmount[account_];
    }

    // ============================================== //
    //                 Access Control                 //
    // ============================================== //

    function grantRole(
        bytes32 role,
        address account
    )
        public
        override(AccessControlUpgradeable, IAccessControl)
        onlyGovernance
    {
        _grantRole(role, account);
    }

    function revokeRole(
        bytes32 role,
        address account
    )
        public
        override(AccessControlUpgradeable, IAccessControl)
        onlyGovernance
    {
        _revokeRole(role, account);
    }
}
