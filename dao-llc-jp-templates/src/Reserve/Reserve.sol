// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IReserve} from "src/interfaces/Reserve/IReserve.sol";
import {EventReserve} from "src/interfaces/Reserve/EventReserve.sol";
import {ErrorReserve} from "src/interfaces/Reserve/ErrorReserve.sol";

contract Reserve is IReserve, EventReserve, ErrorReserve {
    mapping(address account_ => bool) private _admins;
    uint256 private _lastIndex;
    mapping(uint256 index_ => address account_) private _reservers;
    mapping(address account_ => bool listed_) private _whitelist;
    
    constructor() {
        _setAdmin(msg.sender);
    }
    
    function reservation(address account_) external override onlyAdmin returns(bool listed_) {
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(_isWhitelisted(account_)) revert AlreadyReserve(account_);

        if(!_addToWhitelist(account_)) revert DoNotToAddWhitelist(account_);

        listed_ = true;
    }

    function _addToWhitelist(address account_) internal returns(bool listed_) {
        _lastIndex++;
        _reservers[_indexOf()] = account_;

        if(_reserverOf(_indexOf()) == account_) {
            emit NewReserver(account_, _indexOf());

            _whitelist[account_] = true;
        }

        listed_ = _whitelist[account_];
    }

    function cancel(address account_) external override onlyAdmin returns(bool listed_) {
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(!_isWhitelisted(account_)) revert NotyetReserve(account_);

        if(_cancelWhitelist(account_)) revert DoNotToAddWhitelist(account_);

        listed_ = _whitelist[account_];
    }

    function _cancelWhitelist(address account_) internal returns(bool listed_) {
        uint256 _index = 1;

        for(_index; _index <= _lastIndex; _index++){
            if(_reserverOf(_index) == account_) _reservers[_index] = address(0);
            if(_isWhitelisted(account_)) _whitelist[account_] = false;

            if(_reserverOf(_index) == address(0) && !_isWhitelisted(account_)) {
                emit CancelReserve(account_, _index);

                break;
            }
        }

        listed_ = _whitelist[account_];
    }

    function setAdmin(address account_) external override onlyAdmin returns(bool assigned_){
        if(account_ == address(0)) revert InvalidAddress(account_);
        // TODO: Error-handlingの追加をする
        // if(_admins[account_]) revert AlreadyAdmin(account_);

        assigned_ = _setAdmin(account_);
    }

    function deleteAdmin(address account_) external override onlyAdmin returns(bool assigned_){
        if(account_ == address(0)) revert InvalidAddress(account_);
        // TODO: Error-handlingの追加をする
        // if(!_admins[account_]) revert NotAdmin(account_);

        assigned_ = _deleteAdmin(account_);
    }


    function _setAdmin(address account_) internal returns(bool assigned_){
        bool _assigned;

        _admins[account_] = true;

        // TODO: 新規登録した管理者が正常に設定されたかの確認処理を追加する
        _assigned = _admins[account_];

        // TODO: Error-handlingの追加をする
        // if(!_assigned) revert NotSetAdmin(account_);

        // TODO: Event handlingの追加をする
        emit NewAdmin(account_);

        assigned_ = _assigned;
    }

    function _deleteAdmin(address account_) internal returns(bool assigned_){
        bool _assigned;

        delete _admins[account_];

        // TODO: 管理者が正常に削除されたかの確認処理を追加する
        _assigned = _admins[account_];

        // TODO: Error-handlingの追加をする
        // if(_assigned) revert NotDeleteAdmin(account_);

        // TODO: Event handlingの追加をする
        emit DeleteAdmin(account_);

        assigned_ = !_assigned;
    }

    // function _getAdmin(address account_) internal view returns(bool assigned_){
    //     assigned_ = _admins[account_];
    // }
    
    function isWhitelisted(address account_) external view override returns(bool listed_){
        if(account_ == address(0)) revert InvalidAddress(account_);

        listed_ = _isWhitelisted(account_);
    }

    function _isWhitelisted(address account_) internal view returns(bool listed_){
        listed_ = _whitelist[account_];
    }

    function lastIndexOf() external view onlyAdmin returns(uint256 index_){
        index_ = _indexOf();
    }

    function _indexOf() internal view returns(uint256 index_){
        index_ = _lastIndex;
    }

    function reserverOf(uint256 index_) external view onlyAdmin returns(address reserver_){
        if(index_ <= 0 || index_ > _lastIndex) revert InvalidIndex(index_);
        reserver_ = _reserverOf(index_);
    }

    function _reserverOf(uint256 index_) internal view returns(address reserver_){
        reserver_ = _reservers[index_];
    }

    function reserversOf() external view onlyAdmin returns(address[] memory reservers_){
        reservers_ = new address[](_lastIndex);
    
        for(uint256 i = 1; i <= _lastIndex; i++){
            if(_reserverOf(i) != address(0)) reservers_[i -1] = _reserverOf(i);
        }
    }

    modifier onlyAdmin() {
        // TODO: CallerがAdminであるかのチェック処理を追加する
        require(_admins[msg.sender] , "Error: Reserve/Only-Admin");
        _;
    }
}
