// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IBorderlessCompany} from "src/interfaces/IBorderlessCompany.sol";
import {EventBorderlessCompany} from "src/interfaces/EventBorderlessCompany.sol";
import {ErrorBorderlessCompany} from "src/interfaces/ErrorBorderlessCompany.sol";

contract BorderlessCompany is IBorderlessCompany, EventBorderlessCompany, ErrorBorderlessCompany {
    address private _register;
    mapping(address account_ => bool assigned_) private _admins;
    mapping(address account_ => bool assigned_) private _members;
    mapping(uint256 index_ => address service_) private _services;

    constructor(address admin_, address register_) {
        _admins[admin_] = true;
        _register = register_;
    }

    function initialService(address[] calldata services_) external override onlyRegister returns(bool completed_){
        if(_getService(1) != address(0) || _getService(2) != address(0) || _getService(3) != address(0)) revert AlreadyInitialService(msg.sender);
        
        completed_ = _initialService(services_);
    }

    function getService(uint256 index_) external view override onlyAdmin returns(address service_) {
        require(index_ >= 0 && _getService(index_) != address(0), "Error: BorderlessComapny/Invalid-Index");

        service_ = _getService(index_);
    }

    function assignmentRole(address account_, bool isAdmin_) external override onlyAdmin returns(bool assigned_){
        if(account_ == address(0)) revert InvalidAddress(account_);

        if(!isAdmin_) assigned_ = _assignmentRoleMember(account_);
        else assigned_ = _assignmentRoleAdmin(account_);
    }

    function releaseRole(address account_, bool isAdmin_) external override onlyAdmin returns(bool released_){
        if(account_ == address(0)) revert InvalidAddress(account_);

        if(!isAdmin_) released_ = _releaseRoleMember(account_);
        else released_ = _releaseRoleAdmin(account_);
    }

    // -- Internal features -- //

    function _initialService(address[] calldata services_) internal returns(bool completed_){
        for(uint256 _index = 1; _index <= services_.length; _index++) {
            address activatedAddress = services_[_index - 1];
            if (_index == 1) _services[_index] = address(activatedAddress);
            if (_index == 2) _services[_index] = address(activatedAddress);
            if (_index == 3) _services[_index] = address(activatedAddress);
        }

        emit InitialService(address(this), _getService(1), _getService(2), _getService(3));
        completed_ = true;
    }

    function _getService(uint256 index_) internal view returns(address service_) {
        service_ = _services[index_];
    }

    function _assignmentRoleAdmin(address account_) internal returns(bool assigned_){
        if(_admins[account_]) revert AlreadyAssignmentRole(account_);
        
        _admins[account_] = true;
        emit AssignmentRoleAdmin(account_, _admins[account_]);

        assigned_ = _admins[account_];
    }

    function _assignmentRoleMember(address account_) internal returns(bool assigned_){
        if(_members[account_]) revert AlreadyAssignmentRole(account_);
        
        _members[account_] = true;
        emit AssignmentRoleMember(account_, _admins[account_]);

        assigned_ = _members[account_];
    }

    function _releaseRoleAdmin(address account_) internal returns(bool released_){
        if(!_admins[account_]) revert AlreadyReleaseRole(account_);
        
        _admins[account_] = false;
        emit ReleaseRoleAdmin(account_, !_admins[account_]);

        released_ = !_admins[account_];
    }

    function _releaseRoleMember(address account_) internal returns(bool released_){
        if(!_members[account_]) revert AlreadyReleaseRole(account_);
        
        _members[account_] = false;
        emit ReleaseRoleMember(account_, !_admins[account_]);

        released_ = !_members[account_];
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], "Error: BorderlessCompany/Only-Admin");
        _;
    }

    modifier onlyMember() {
        require(_members[msg.sender], "Error: BorderlessCompany/Only-Member");
        _;
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: BorderlessCompany/Only-Register");
        _;
    }
}
