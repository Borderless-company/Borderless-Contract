// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {FactoryServiceBase} from "./FactoryServiceBase.sol";
import {TreasuryService} from "../../Services/TreasuryService.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

/// @title Treasury smart contract for Borderless.company service
contract TreasuryServiceFactory is FactoryServiceBase {
    // ============================================== //
    //                   Initializer                  //
    // ============================================== //

    function initialize(
        address implementation_,
        address register_
    ) external initializer {
        __FactoryServiceBase_init(implementation_, register_);
    }

    // ============================================== //
    //              External Write Functions          //
    // ============================================== //

    function activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) external override onlyRegister returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    // ============================================== //
    //             Internal Write Functions           //
    // ============================================== //

    function _createService(
        address admin_,
        address company_
    ) internal override returns (address) {
        // BeaconProxyの初期化データをエンコード
        bytes memory initData = abi.encodeWithSelector(
            TreasuryService.initialize.selector,
            admin_,
            company_
        );

        // BeaconProxyを使用して新しいサービスインスタンスをデプロイ
        BeaconProxy proxy = new BeaconProxy(address(beacon), initData);
        address proxyAddress = address(proxy);

        emit ProxyCreated(
            uint256(keccak256(abi.encodePacked(admin_, company_))),
            proxyAddress
        );

        return proxyAddress;
    }
}
