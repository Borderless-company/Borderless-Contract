// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FactoryServiceBase} from "../FactoryPool/FactoryServices/FactoryServiceBase.sol";
import {SampleService} from "./SampleService.sol";

/// @title Test factory sample smart contract for Borderless.company service
contract BaseSampleFactory is FactoryServiceBase {
    address private _admin;
    address private _company;

    function initialize(
        address implementation_,
        address register_
    ) external initializer {
        __FactoryServiceBase_init(implementation_, register_);
    }

    function activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) external override onlyRegister returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    function _createService(
        address admin_,
        address company_
    ) internal override returns (address) {
        return address(new SampleService(admin_, company_));
    }
}
