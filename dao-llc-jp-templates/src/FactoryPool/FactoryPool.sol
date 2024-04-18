// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IFactoryPool} from "src/interfaces/FactoryPool/IFactoryPool.sol";
import {EventFactoryPool} from "src/interfaces/FactoryPool/EventFactoryPool.sol";
import {ErrorFactoryPool} from "src/interfaces/FactoryPool/ErrorFactoryPool.sol";

contract FactoryPool is IFactoryPool, EventFactoryPool, ErrorFactoryPool {
    address private _owner;
    address private _register;
    uint256 private _lastIndex;
    mapping(uint256 index_ => ServiceInfo info_) private _services;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function setService(address service_) external override onlyOwner {
        if(service_ == address(0)) revert InvalidParam(service_, 0, false);
        
        _setService(service_);
    }

    function _setService(address service_) internal {
        ServiceInfo memory _info;
        (bool _updated, uint256 _index) = _incrementLastIndex();

        if(!_updated) revert DoNotSetService(service_);

        _info.service = service_;
        _info.createAt = block.timestamp;
        _info.updateAt = block.timestamp;

        _services[_index] = _info;

        emit NewService(_info.service, _index);
    }

    function getService(uint256 index_) external view override onlyRegister returns(address service_, bool online_){
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

    function _incrementLastIndex() private returns(bool updated_, uint256 index_){
        uint256 _currentIndex = _getLatestIndex();
        _lastIndex++;
        uint256 _updateIndex = _getLatestIndex();

        if(_currentIndex + 1 == _updateIndex) (updated_, index_) = (true, _updateIndex);
    }

    function getLatestIndex() external view onlyRegister returns(uint256 index_) {
        index_ = _getLatestIndex();
    }

    function _getLatestIndex() private view returns(uint256 index_) {
        index_ = _lastIndex;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Error: FactoryPool/Only-Owner");
        _;
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: FactoryPool/Only-Register");
        _;
    }
}
