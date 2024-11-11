// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {IFactoryService} from "../interfaces/FactoryServices/IFactoryService.sol";
import {EventFactoryService} from "../interfaces/FactoryServices/EventFactoryService.sol";
import {ErrorFactoryService} from "../interfaces/FactoryServices/ErrorFactoryService.sol";
import {BeaconUpgradeableBase} from "../../upgradeable/BeaconUpgradeableBase.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

abstract contract FactoryServiceBase is
    BeaconUpgradeableBase,
    UUPSUpgradeable,
    IFactoryService,
    EventFactoryService,
    ErrorFactoryService
{
    // ============================================== //
    //                State Variables                 //
    // ============================================== //

    address private _register;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: FactoryService/Only-Register");
        _;
    }

    // ============================================== //
    //                   Initializer                  //
    // ============================================== //

    function __FactoryServiceBase_init(
        address implementation_,
        address register_
    ) internal initializer {
        __BeaconUpgradeableBase_init(implementation_);
        _register = register_;
    }

    // ============================================== //
    //                External Functions              //
    // ============================================== //

    function activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) external virtual returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    // ============================================== //
    //                Internal Functions              //
    // ============================================== //

    function _activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) internal returns (address service_) {
        service_ = _createService(admin_, company_);

        if (service_ == address(0))
            revert DoNotActivateService(msg.sender, company_, serviceID_);

        emit ActivateBorderlessService(msg.sender, service_, serviceID_);
    }

    // サービスインスタンスを作成する抽象メソッド
    function _createService(
        address admin_,
        address company_
    ) internal virtual returns (address);

    // ---------------------------------------------- //
    //                     UUPS                       //
    // ---------------------------------------------- //

    function _authorizeUpgrade(address newImplementation) internal override onlyRegister {}

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) public payable override onlyRegister {
        super.upgradeToAndCall(newImplementation, data);
    }
}
