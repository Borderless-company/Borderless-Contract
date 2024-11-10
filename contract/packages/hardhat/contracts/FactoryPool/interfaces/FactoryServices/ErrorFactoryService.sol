// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Error interface for FactoryService contract
interface ErrorFactoryService {
    /**
     * @dev サービスが有効化されていないことを通知するエラーです。
     * @param account_ エラーが発生したアカウントのアドレスです。
     * @param company_ エラーが発生した企業のアドレスです。
     * @param serviceID_ エラーが発生したサービスのIDです。
     */
    error DoNotActivateService(
        address account_,
        address company_,
        uint256 serviceID_
    );
}
