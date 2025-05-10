// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as ACStorage} from "../../BorderlessAccessControl/storages/Storage.sol";

// lib
import {AccessControlLib} from "../../BorderlessAccessControl/lib/AccessControlLib.sol";

// interfaces
import {ISCT} from "../interfaces/ISCT.sol";
import {ServiceType} from "../../utils/ITypes.sol";
import {Constants} from "../../lib/Constants.sol";

// Access Control
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {console} from "hardhat/console.sol";

/// @title SCT (Smart Company Template) contract
contract SCT is ISCT, Initializable, AccessControlEnumerableUpgradeable {
    // ============================================== //
    //                  Storage                       //
    // ============================================== //

    address private _scr;

    /**
     * @dev service type => service address
     */
    mapping(ServiceType serviceType => address service)
        private _serviceContracts;

    /**
     * @dev account => investment amount
     */
    mapping(address account => uint256 investmentAmount)
        private _investmentAmount;

    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    modifier onlyGovernanceOrFounder() {
        require(
            (_serviceContracts[ServiceType.GOVERNANCE] != address(0) &&
                msg.sender == _serviceContracts[ServiceType.GOVERNANCE]) ||
                (
                    AccessControlLib.hasRole(
                        ACStorage.AccessControlSlot(),
                        Constants.FOUNDER_ROLE,
                        msg.sender
                    )
                ),
            NotGovernanceOrFounder(msg.sender)
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

    /// @notice Initialize the SCT
    function __SCT_initialize(address founder, address scr) internal initializer {
        console.log("call __SCT_initialize");
        _scr = scr;
        _grantRole(Constants.DEFAULT_ADMIN_ROLE, founder);
    }

    // ============================================== //
    //            External Write Functions            //
    // ============================================== //

    function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) external returns (bool completed) {
        require(
            AccessControlLib.hasRole(
                ACStorage.AccessControlSlot(),
                Constants.FOUNDER_ROLE,
                msg.sender
            ) || msg.sender == _scr,
            NotFounderOrSCR(msg.sender)
        );
        for (uint256 index = 0; index < serviceTypes.length; index++) {
            address activatedAddress = services[index];
            require(
                activatedAddress != address(0),
                InvalidAddress(activatedAddress)
            );
            _serviceContracts[serviceTypes[index]] = activatedAddress;
        }

        emit RegisterService(address(this), serviceTypes, services);
        completed = true;
    }

    function setInvestmentAmount(
        address account,
        uint256 investmentAmount
    ) external onlyRole(Constants.TREASURY_ROLE) {
        _investmentAmount[account] = investmentAmount;
    }

    // ============================================== //
    //            External Read Functions             //
    // ============================================== //

    function getSCR() external view returns (address scr) {
        scr = _scr;
    }

    function getService(
        ServiceType serviceType
    ) external view returns (address service) {
        service = _serviceContracts[serviceType];
    }

    function getInvestmentAmount(
        address account
    ) external view returns (uint256 investmentAmount) {
        investmentAmount = _investmentAmount[account];
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
        onlyGovernanceOrFounder
    {
        _grantRole(role, account);
    }

    function revokeRole(
        bytes32 role,
        address account
    )
        public
        override(AccessControlUpgradeable, IAccessControl)
        onlyGovernanceOrFounder
    {
        _revokeRole(role, account);
    }
}
