// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;


import {FactoryServiceBase} from "src/FactoryPool/FactoryServices/FactoryServiceBase.sol";
import {TreasuryService} from "src/Services/TreasuryService.sol";

/// @title Treasury smart contract for Borderless.company service
contract TreasuryServiceFactory is FactoryServiceBase {
    address private _admin;
    address private _company;

    constructor(address register_) FactoryServiceBase(register_) {}

    function activate(address admin_, address company_, uint256 serviceID_) external override onlyRegister returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    function _activate(address admin_, address company_, uint256 serviceID_) internal override returns (address service_) {
        // Note: common service setup
        TreasuryService service = new TreasuryService(admin_, company_);

        if(address(service) == address(0)) revert DoNotActivateService(admin_, company_, serviceID_);

        emit ActivateBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }
}
