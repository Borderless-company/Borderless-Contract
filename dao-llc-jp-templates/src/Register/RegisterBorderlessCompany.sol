// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IWhitelist} from "src/interfaces/Whitelist/IWhitelist.sol";
import {IRegisterBorderlessCompany} from "src/interfaces/Register/IRegisterBorderlessCompany.sol";
import {EventRegisterBorderlessCompany} from "src/interfaces/Register/EventRegisterBorderlessCompany.sol";
import {ErrorRegisterBorderlessCompany} from "src/interfaces/Register/ErrorRegisterBorderlessCompany.sol";

contract RegisterBorderlessCompany is IRegisterBorderlessCompany, EventRegisterBorderlessCompany, ErrorRegisterBorderlessCompany {
    IWhitelist private _whitelist;
    address private _owner;
    uint256 private _lastIndex;
    mapping (uint256 index_ => CompanyInfo companyInfo_) private _companies;

    constructor(address whitelist_) {
        _owner = msg.sender;
        _whitelist = IWhitelist(whitelist_);
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

    function _createBorderlessCompany(CompanyInfo memory info_) private returns(bool started_, address companyAddress_) {
        bool _updated;
        uint256 _index;
        
        BorderlessCompany _company = new BorderlessCompany(info_.founder);
        if (address(_company) == address(0)) revert DoNotCreateBorderlessCompany(msg.sender);
        
        (_updated, _index) = _incrementLastIndex();

        if(_updated) {
            info_.companyAddress = address(_company);
            _companies[_index] = info_;

            emit NewBorderlessCompany(info_.founder, info_.companyAddress, _lastIndex);

            (started_, companyAddress_) = (true, info_.companyAddress);
        } else {
            revert DoNotCreateBorderlessCompany(msg.sender);
        }
    }

    function _incrementLastIndex() private returns(bool updated_, uint256 index_){
        uint256 _currentIndex = _getLatestIndex();
        _lastIndex++;
        uint256 _updateIndex = _getLatestIndex();

        if(_currentIndex + 1 == _updateIndex) (updated_, index_) = (true, _lastIndex);
    }

    function _getLatestIndex() private view returns(uint256) {
        return _lastIndex;
    }

    modifier onlyFounder() {
        require(_whitelist.isWhitelisted(msg.sender) , "Error: Register/Only-Founder");
        _;
    }
}
