// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IFactoryService} from "src/interfaces/FactoryPool/FactoryServices/IFactoryService.sol";
import {EventFactoryService} from "src/interfaces/FactoryPool/FactoryServices/EventFactoryService.sol";

// -- Factory Template contract -- //

/// @title Test factory smart contract for Borderless.company service
contract TreasuryServiceFactory is IFactoryService, EventFactoryService {
    address private _owner;
    address private _register;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function activate(address admin_, address company_, uint256 serviceID_) external override onlyRegister returns (address service_) {
        /// Note: common service setup
        TreasuryService service = new TreasuryService(admin_, company_); // Note: **この箇所を変更する**

        if(address(service) == address(0)) revert DoNotActivateService(admin_, company_, serviceID_); // Note: **この箇所を変更する**

        emit ActivateBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }

    // TODO: documentとerror-handlingを追加する
    error DoNotActivateService(address account_, address company_, uint256 serviceID_);

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: FactoryService/Only-Register");
        _;
    }
}

// TODO: 正規に、ディレクトリとソースコード整理をする
interface ITreasuryService {
    function callAdmin() external returns(bool);
}

/// @title Test smart contract for Borderless.company service
contract TreasuryService is ITreasuryService {
    address private _admin;
    address private _company;

    constructor(address admin_, address company_) {
        _admin = admin_;
        _company = company_;
    }

    function callAdmin() public view onlyOwner returns (bool called_) {
        called_ = true;
    }

    modifier onlyService() {
        require(_validateCaller(), "Error: TreasuryService/Invalid-Caller");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == _admin, "Error: TreasuryService/Only-Owner");
        _;
    }

    function _validateCaller() internal view returns (bool called_) {
        if(msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}
