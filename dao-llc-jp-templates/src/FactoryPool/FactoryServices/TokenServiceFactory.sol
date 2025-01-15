// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {FactoryServiceBase} from "src/FactoryPool/FactoryServices/FactoryServiceBase.sol";
import {LETSService} from "src/Services/LETSService.sol";

/// @title Token smart contract for Borderless.company service
contract TokenServiceFactory is FactoryServiceBase {
    constructor(address register_) FactoryServiceBase(register_) {}

    function activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) external override onlyRegister returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    function _activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) internal override returns (address service_) {
        // Note: common service setup
        LETSService service = new LETSService(admin_, company_);

        if (address(service) == address(0))
            revert DoNotActivateService(admin_, company_, serviceID_);

        emit ActivateBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }
}
