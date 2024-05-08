// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Event interface
interface EventFactoryPool {
   /**
   * @dev 新しいサービスが追加されたことを通知するイベントです。
   * @param service_ 追加されたサービスのアドレスです。
   * @param index_ サービスのインデックスです。
   */
   event NewService(address indexed service_, uint256 indexed index_);

   /**
   * @dev サービスの状態が更新されたことを通知するイベントです。
   * @param service_ 更新されたサービスのアドレスです。
   * @param index_ サービスのインデックスです。
   * @param online_ サービスのオンライン状態です。
   */
   event UpdateService(address indexed service_, uint256 indexed index_, bool online_);

   /**
    * @dev コントラクト管理者が追加されたときに発生するイベント
    * @param account_ 新しく追加された管理者アカウントのアドレス
    */
    event NewAdmin(address indexed account_);

    /**
    * @dev コントラクト管理者が削除されたときに発生するイベント
    * @param account_ 削除された管理者アカウントのアドレス
    */
    event RemoveAdmin(address indexed account_);
}
