// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {FactoryServiceBase} from "./FactoryServiceBase.sol";
import {GovernanceService} from "../../Services/GovernanceService.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

/// @title Governance smart contract for Borderless.company service
contract GovernanceServiceFactory is FactoryServiceBase {
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
    //                External Functions              //
    // ============================================== //

    function activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) external override onlyRegister returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    // ============================================== //
    //                Internal Functions              //
    // ============================================== //

    /// @notice Creates a new instance of GovernanceService using BeaconProxy
    /// @param admin_ The administrator address
    /// @param company_ The company address
    /// @return The address of the newly created GovernanceService instance
    function _createService(
        address admin_,
        address company_
    ) internal override returns (address) {
        // BeaconProxyの初期化データをエンコード
        bytes memory initData = abi.encodeWithSelector(
            GovernanceService.initialize.selector,
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
