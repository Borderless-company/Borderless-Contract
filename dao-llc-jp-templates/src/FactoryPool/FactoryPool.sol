// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IFactoryPool} from "src/interfaces/FactoryPool/IFactoryPool.sol";
import {EventFactoryPool} from "src/interfaces/FactoryPool/EventFactoryPool.sol";
import {ErrorFactoryPool} from "src/interfaces/FactoryPool/ErrorFactoryPool.sol";

contract FactoryPool is IFactoryPool, EventFactoryPool, ErrorFactoryPool {
    address private _owner;
    address private _register;
    mapping(uint256 index_ => ServiceInfo info_) private _services;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function setService(address service_, uint256 index_) external override onlyOwner {
        if(service_ == address(0) || index_ <= 0) revert InvalidParam(service_, index_, false);
        if(_services[index_].service != address(0)) revert InvalidParam(service_, index_, false);
        
        _setService(service_, index_);
    }

    function _setService(address service_, uint256 index_) internal {
        ServiceInfo memory _info;

        _info.service = service_;
        _info.createAt = block.timestamp;
        _info.updateAt = block.timestamp;

        _services[index_] = _info;

        emit NewService(_info.service, index_);
    }

    function getService(uint256 index_) external view override onlyValidCaller returns(address service_, bool online_){
        if(index_ <= 0) revert InvalidParam(msg.sender, index_, false);

        ServiceInfo memory _info = _services[index_];
        (service_, online_) = (_info.service, _info.online);
    }

    function updateService(address service_, uint256 index_) external override onlyOwner{
        ServiceInfo memory _info;
        if(index_ <= 0 || service_ == address(0)) revert InvalidParam(service_, index_, false);

        _info = _services[index_];
        if(service_ == _info.service) revert InvalidParam(service_, index_, false);

        _info.service = service_;
        
        _updateService(_info, index_);
    }

    function updateService(address service_, uint256 index_, bool online_) external override onlyOwner{
        ServiceInfo memory _info;
        if(index_ <= 0 || service_ == address(0)) revert InvalidParam(service_, index_, online_);
        if(online_ == _services[index_].online) revert InvalidParam(service_, index_, online_);

        _info = _services[index_];
        if(service_ != _info.service) revert InvalidParam(service_, index_, false);

        _info.online = online_;
        
        _updateService(_info, index_);
    }

    function _updateService(ServiceInfo memory info_, uint256 index_) private {
        info_.updateAt = block.timestamp;
        _services[index_] = info_;

        emit UpdateService(info_.service, index_, info_.online);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Error: FactoryPool/Only-Owner");
        _;
    }

    modifier onlyValidCaller() {
        require(_validateCaller(), "Error: FactoryPool/Invalid-Caller");
        _;
    }

    function _validateCaller() internal view returns(bool valid_){
        if(msg.sender == _owner || msg.sender == _register) valid_ = true;
    }
}
