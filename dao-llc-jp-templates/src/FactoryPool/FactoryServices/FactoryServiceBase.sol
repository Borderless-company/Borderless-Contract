// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IFactoryService} from "src/interfaces/FactoryPool/FactoryServices/IFactoryService.sol";
import {EventFactoryService} from "src/interfaces/FactoryPool/FactoryServices/EventFactoryService.sol";
import {ErrorFactoryService} from "src/interfaces/FactoryPool/FactoryServices/ErrorFactoryService.sol";

abstract contract FactoryServiceBase is IFactoryService, EventFactoryService, ErrorFactoryService {
    address private _owner;
    address private _register;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function activate(address admin_, address company_, uint256 serviceID_) external virtual returns (address service_){
        service_ = _activate(admin_, company_, serviceID_);
    }

    function _activate(address admin_, address company_, uint256 serviceID_) internal virtual returns (address service_);

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: FactoryService/Only-Register");
        _;
    }
}
