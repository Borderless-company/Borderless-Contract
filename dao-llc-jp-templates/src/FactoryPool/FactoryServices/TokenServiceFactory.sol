// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IFactoryService} from "src/interfaces/FactoryPool/FactoryServices/IFactoryService.sol";
import {EventFactoryService} from "src/interfaces/FactoryPool/FactoryServices/EventFactoryService.sol";
import {ErrorFactoryService} from "src/interfaces/FactoryPool/FactoryServices/ErrorFactoryService.sol";
import {TokenService} from "src/Services/TokenService.sol";

/// @title Test factory smart contract for Borderless.company service
contract TokenServiceFactory is IFactoryService, EventFactoryService, ErrorFactoryService {
    address private _owner;
    address private _register;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function activate(address admin_, address company_, uint256 serviceID_) external override onlyRegister returns (address service_) {
        /// Note: common service setup
        TokenService service = new TokenService(admin_, company_); // Note: **この箇所を変更する**

        if(address(service) == address(0)) revert DoNotActivateService(admin_, company_, serviceID_); // Note: **この箇所を変更する**

        emit ActivateBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: FactoryService/Only-Register");
        _;
    }
}
