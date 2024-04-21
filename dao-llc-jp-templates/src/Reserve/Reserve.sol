// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IReserve} from "src/interfaces/Reserve/IReserve.sol";
import {EventReserve} from "src/interfaces/Reserve/EventReserve.sol";
import {ErrorReserve} from "src/interfaces/Reserve/ErrorReserve.sol";

contract Reserve is IReserve, EventReserve, ErrorReserve {
    address private _owner;
    uint256 private _lastIndex;
    mapping(uint256 index_ => address account_) private _reservers;
    mapping(address account_ => bool listed_) private _whitelist;
    
    constructor() {
        _owner = msg.sender;
    }
    
    function reservation(address account_) external override onlyOwner returns(bool listed_) {
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(_isWhitelisted(account_)) revert AlreadyReserver(account_);

        if(!_addToWhitelist(account_)) revert DoNotToAddWhitelist(account_);

        listed_ = true;
    }

    function _addToWhitelist(address account_) internal returns(bool listed_) {
        _lastIndex++;
        _reservers[_lastIndex] = account_;

        emit NewReserver(msg.sender, account_);

        _whitelist[account_] = true;

        listed_ = _whitelist[account_];
    }
    
    function isWhitelisted(address account_) external view override returns(bool listed_){
        if(account_ == address(0)) revert InvalidAddress(account_);

        listed_ = _isWhitelisted(account_);
    }

    function _isWhitelisted(address account_) internal view returns(bool listed_){
        listed_ = _whitelist[account_];
    }

    function lastIndexOf() external view onlyOwner returns(uint256 index_){
        index_ = _lastIndex;
    }

    function reserverOf(uint256 index_) external view onlyOwner returns(address reserver_){
        reserver_ = _reservers[index_];
    }

    function reserversOf() external view onlyOwner returns(address[] memory reservers_){
        reservers_ = new address[](_lastIndex);
    
        for(uint256 i = 1; i <= _lastIndex; i++){
            if(_reservers[i] != address(0)) reservers_[i -1] = _reservers[i];
        }
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Error: Reserve/Only-Owner");
        _;
    }
}
