// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for factory service
interface IFactoryService {
    /**
     * @dev 管理者がサービスを有効化するための関数です。
     * @param admin_ サービスを有効化する管理者のアドレスです。
     * @param company_ サービスを提供する企業のアドレスです。
     * @param serviceID_ 有効化するサービスのIDです。
     * @return service_ 有効化されたサービスのアドレスです。
     */
    function activate(
        address admin_,
        address company_,
        uint256 serviceID_
    ) external returns (address service_);
}
