// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IRegisterBorderlessCompany} from "src/interfaces/Register/IRegisterBorderlessCompany.sol";
import {EventRegisterBorderlessCompany} from "src/interfaces/Register/EventRegisterBorderlessCompany.sol";
import {ErrorRegisterBorderlessCompany} from "src/interfaces/Register/ErrorRegisterBorderlessCompany.sol";
import {IReserve} from "src/interfaces/Reserve/IReserve.sol";
import {IFactoryPool} from "src/interfaces/FactoryPool/IFactoryPool.sol";
import {IFactoryService} from "src/interfaces/FactoryPool/FactoryServices/IFactoryService.sol";
import {BorderlessCompany, IBorderlessCompany} from "src/BorderlessCompany.sol";

contract RegisterBorderlessCompany is IRegisterBorderlessCompany, EventRegisterBorderlessCompany, ErrorRegisterBorderlessCompany {
    IReserve private _reserve;
    IFactoryPool private _facotryPool;

    mapping(address account_ => bool assigned_) private _admins;
    uint256 private _lastIndex;
    mapping (uint256 index_ => CompanyInfo companyInfo_) private _companies;

    constructor(address reserve_) {
        _addAdmin(msg.sender);
        _reserve = IReserve(reserve_);
    }

    function createBorderlessCompany(bytes calldata companyID_, bytes calldata establishmentDate_, bool confirmed_) external override onlyFounder returns(bool started_, address companyAddress_) {
        CompanyInfo memory _info;
        if (companyID_.length == 0 || establishmentDate_.length == 0 || !confirmed_) revert InvalidCompanyInfo(msg.sender);

        _info.founder = msg.sender;
        _info.companyID = companyID_;
        _info.establishmentDate = establishmentDate_;
        _info.confirmed = confirmed_;
        _info.createAt = block.timestamp;
        _info.updateAt = block.timestamp;

        (started_, companyAddress_) = _createBorderlessCompany(_info);
    }

    function setFactoryPool(address factoryPool_) external override onlyAdmin {
        if(factoryPool_ == address(0)) revert InvalidParam(factoryPool_);

        _facotryPool = IFactoryPool(factoryPool_);

        emit SetFactoryPool(msg.sender, factoryPool_);
    }

    // -- Internal features -- //

    function _createBorderlessCompany(CompanyInfo memory info_) private returns(bool started_, address companyAddress_) {
        bool _updated;
        bool _completed;
        uint256 _index;
        
        BorderlessCompany _company = new BorderlessCompany(info_.founder, address(this));
        if (address(_company) != address(0)) (_updated, _index) = _incrementLastIndex();
        
        if(!_updated) revert DoNotCreateBorderlessCompany(msg.sender);

        info_.companyAddress = address(_company);
        _companies[_index] = info_;

        _completed = _setupService(info_.founder, info_.companyAddress);

        if(_completed) emit NewBorderlessCompany(info_.founder, info_.companyAddress, _index);
            
        (started_, companyAddress_) = (_completed, info_.companyAddress);
    }

    function _setupService(address admin_, address company_) internal returns(bool completed_){
        address _service;
        bool _online;
        uint8 _serviceIndex = 3;
        address[] memory _services = new address[](_serviceIndex);

        for(uint256 _index = 1; _index <= _serviceIndex; _index++) {
            (_service, _online) = _facotryPool.getService(_index);

            if(_online) {
                address activatedAddress = IFactoryService(_service).activate(admin_, company_, _index);
                _services[_index - 1] = activatedAddress;
            }
        }

        completed_ = IBorderlessCompany(company_).initialService(_services);
    }

    function _incrementLastIndex() private returns(bool updated_, uint256 index_){
        uint256 _currentIndex = _getLatestIndex();
        _lastIndex++;
        uint256 _updateIndex = _getLatestIndex();

        if(_currentIndex + 1 == _updateIndex) (updated_, index_) = (true, _updateIndex);
    }

    function _getLatestIndex() private view returns(uint256) {
        return _lastIndex;
    }

    // -- Register Access Control -- //

    modifier onlyFounder() {
        require(_reserve.isWhitelisted(msg.sender), "Error: Register/Only-Founder");
        _;
    }

    // -- Admin Access Control -- //
    function addAdmin(address account_) external override onlyAdmin returns(bool assigned_){
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(_isAdmin(account_)) revert AlreadyAdmin(account_);

        assigned_ = _addAdmin(account_);
    }

    function removeAdmin(address account_) external override onlyAdmin returns(bool assigned_){
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(!_isAdmin(account_)) revert NotAdmin(account_);

        assigned_ = _removeAdmin(account_);
    }

    function _addAdmin(address account_) internal returns(bool assigned_){
        bool _assigned;

        _admins[account_] = true;
        _assigned = _isAdmin(account_);

        if(!_assigned) revert DoNotAddAdmin(account_);

        emit NewAdmin(account_);

        assigned_ = _assigned;
    }

    function _removeAdmin(address account_) internal returns(bool assigned_){
        bool _assigned;

        delete _admins[account_];
        _assigned = _isAdmin(account_);

        if(_assigned) revert DoNotRemoveAdmin(account_);

        emit RemoveAdmin(account_);

        assigned_ = !_assigned;
    }

    function isAdmin(address account_) external view onlyAdmin returns(bool assigned_){
        assigned_ = _isAdmin(account_);
    }

    function _isAdmin(address account_) internal view returns(bool assigned_){
        assigned_ = _admins[account_];
    }

    modifier onlyAdmin() {
        require(_isAdmin(msg.sender), "Error: Register/Only-Admin");
        _;
    }

}
