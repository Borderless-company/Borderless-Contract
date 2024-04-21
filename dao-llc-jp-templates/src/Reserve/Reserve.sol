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

        listed_ = _addToWhitelist(account_);
    }

    function _addToWhitelist(address account_) internal returns(bool listed_) {
        _whitelist[account_] = true;
        
        if(_isWhitelisted(account_)) {
            emit NewReserver(msg.sender, account_);

            listed_ = true;
        } else {
            revert DoNotToAddWhitelist(account_);
        }
    }
    
    function isWhitelisted(address account_) external view override returns(bool listed_){
        if(account_ == address(0)) revert InvalidAddress(account_);

        listed_ = _isWhitelisted(account_);
    }

    function _isWhitelisted(address account_) internal view returns(bool listed_){
        listed_ = _whitelist[account_];
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Error: Reserve/Only-Owner");
        _;
    }
}
