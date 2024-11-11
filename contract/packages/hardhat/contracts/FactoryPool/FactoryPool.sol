// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {IFactoryPool} from "./interfaces/IFactoryPool.sol";
import {EventFactoryPool} from "./interfaces/EventFactoryPool.sol";
import {ErrorFactoryPool} from "./interfaces/ErrorFactoryPool.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract FactoryPool is
    IFactoryPool,
    EventFactoryPool,
    ErrorFactoryPool,
    Initializable,
    UUPSUpgradeable
{
    // ============================================== //
    //              State Variables                   //
    // ============================================== //
    uint256 private _adminCount;
    address private _register;
    mapping(address account_ => bool assigned_) private _admins;
    mapping(uint256 index_ => ServiceInfo info_) private _services;

    // ============================================== //
    //                   Modifier                     //
    // ============================================== //

    modifier onlyAdmin() {
        if (!_isAdmin(msg.sender)) revert NotAdmin(msg.sender);
        _;
    }

    modifier invalidAddress(address account_) {
        if (account_ == address(0)) revert InvalidAddress(account_);
        _;
    }

    modifier checkParam(
        address service_,
        uint256 index_,
        bool online_
    ) {
        if (service_ == address(0) || index_ <= 0)
            revert InvalidParam(service_, index_, online_);
        _;
    }

    // ============================================== //
    //                   Initializer                  //
    // ============================================== //

    function initialize(
        address register_
    ) external initializer {
        _addAdmin(msg.sender);
        _register = register_;
    }

    // ============================================== //
    //                External Functions              //
    // ============================================== //

    function setService(
        address service_,
        uint256 index_
    ) external override onlyAdmin checkParam(service_, index_, false) {
        if (_services[index_].service != address(0))
            revert InvalidParam(service_, index_, false);

        _setService(service_, index_);
    }

    function updateService(
        address service_,
        uint256 index_
    ) external override onlyAdmin checkParam(service_, index_, false) {
        ServiceInfo memory _info;

        _info = _services[index_];
        if (service_ == _info.service)
            revert InvalidParam(service_, index_, false);

        _info.service = service_;

        _updateService(_info, index_);
    }

    function updateService(
        address service_,
        uint256 index_,
        bool online_
    ) external override onlyAdmin checkParam(service_, index_, online_) {
        ServiceInfo memory _info;
        if (online_ == _services[index_].online)
            revert InvalidParam(service_, index_, online_);

        _info = _services[index_];
        if (service_ != _info.service)
            revert InvalidParam(service_, index_, false);

        _info.online = online_;

        _updateService(_info, index_);
    }

    function getService(
        uint256 index_
    )
        external
        view
        override
        onlyValidCaller
        returns (address service_, bool online_)
    {
        if (index_ <= 0) revert InvalidParam(msg.sender, index_, false);

        ServiceInfo memory _info = _services[index_];
        (service_, online_) = (_info.service, _info.online);
    }

    // ============================================== //
    //                Internal Features              //
    // ============================================== //

    function _setService(address service_, uint256 index_) internal {
        ServiceInfo memory _info;

        _info.service = service_;
        _info.createAt = block.timestamp;
        _info.updateAt = block.timestamp;

        _services[index_] = _info;

        emit NewService(_info.service, index_);
    }

    function _updateService(ServiceInfo memory info_, uint256 index_) private {
        info_.updateAt = block.timestamp;
        _services[index_] = info_;

        emit UpdateService(info_.service, index_, info_.online);
    }

    // ============================================== //
    //       FactoryPool Access Control               //
    // ============================================== //

    modifier onlyValidCaller() {
        if (!_validateCaller()) revert InvalidCaller(msg.sender);
        _;
    }

    function _validateCaller() internal view returns (bool valid_) {
        if (_isAdmin(msg.sender) || msg.sender == _register) valid_ = true;
    }

    // ============================================== //
    //             Admin Access Control               //
    // ============================================== //

    function addAdmin(
        address account_
    )
        external
        override
        onlyAdmin
        invalidAddress(account_)
        returns (bool assigned_)
    {
        if (_isAdmin(account_)) revert AlreadyAdmin(account_);

        assigned_ = _addAdmin(account_);
    }

    function removeAdmin(
        address account_
    )
        external
        override
        onlyAdmin
        invalidAddress(account_)
        returns (bool assigned_)
    {
        if (!_isAdmin(account_)) revert NotAdmin(account_);
        if (_adminCount <= 1) revert LastAdmin(account_);

        assigned_ = _removeAdmin(account_);
    }

    function _addAdmin(address account_) internal returns (bool assigned_) {
        _admins[account_] = true;

        if (!_isAdmin(account_)) revert DoNotAddAdmin(account_);
        _adminCount++;

        emit NewAdmin(account_, _adminCount);

        assigned_ = true;
    }

    function _removeAdmin(address account_) internal returns (bool assigned_) {
        delete _admins[account_];

        if (_isAdmin(account_)) revert DoNotRemoveAdmin(account_);
        _adminCount--;

        emit RemoveAdmin(account_, _adminCount);

        assigned_ = false;
    }

    function isAdmin(
        address account_
    ) external view onlyAdmin returns (bool assigned_) {
        assigned_ = _isAdmin(account_);
    }

    function _isAdmin(address account_) internal view returns (bool assigned_) {
        assigned_ = _admins[account_];
    }

    // ---------------------------------------------- //
    //                     UUPS                       //
    // ---------------------------------------------- //

    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {}

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) public payable override onlyAdmin {
        super.upgradeToAndCall(newImplementation, data);
    }
}
