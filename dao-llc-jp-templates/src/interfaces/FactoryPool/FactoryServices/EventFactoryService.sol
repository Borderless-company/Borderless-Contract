// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title common interface for factory service
interface EventFactoryService {
    /**
    * @dev ボーダーレスサービスが有効化されたことを通知するイベントです。
    * @param admin_ サービスを有効化した管理者のアドレスです。
    * @param service 有効化されたサービスのアドレスです。
    * @param serviceID 有効化されたサービスのIDです。
    */
    event ActivateBorderlessService(address indexed admin_, address indexed service, uint256 indexed serviceID);
}
