// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IWhitelist} from "src/interfaces/Whitelist/IWhitelist.sol";
import {EventWhitelist} from "src/interfaces/Whitelist/EventWhitelist.sol";
import {ErrorWhitelist} from "src/interfaces/Whitelist/ErrorWhitelist.sol";

contract Whitelist is IWhitelist, EventWhitelist, ErrorWhitelist {
    address private _owner;
    mapping(address account_ => bool listed_) private _whitelist;
    
    constructor() {
        _owner = msg.sender;
    }
    
    function addToWhitelist(address account_) external override onlyOwner returns(bool listed_) {
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(_isWhitelisted(account_)) revert ReserverAlready(account_);

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
        require(msg.sender == _owner, "Error: Whitelist/Only-Owner");
        _;
    }
}
