// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Error interface
interface ErrorFactoryPool {
   /**
   * @dev パラメータが無効な場合に発生するエラーです。
   * @param service_ エラーが発生したサービスのアドレスです。
   * @param index_ エラーが発生したインデックスです。
   * @param online_ エラーが発生したオンライン状態です。
   */
   error InvalidParam(address service_, uint256 index_, bool online_);

   /**
   * @dev 無効なアドレスが提供された場合に発生するエラー
   * @param account_ 無効なアドレスとして提供されたアカウント
   */
   error InvalidAddress(address account_);

   /**
   * @dev サービスが設定されていない場合に発生するエラーです。
   * @param service_ エラーが発生したサービスのアドレスです。
   */
   error DoNotSetService(address service_);

   /**
    * @dev 既に登録済みの管理アカウントが提供された場合に発生するエラー
    * @param account_ 既に登録された管理アカウント
    */
    error AlreadyAdmin(address account_);

    /**
    * @dev 登録なしの管理アカウントが提供された場合に発生するエラー
    * @param account_ 登録がない管理アカウント
    */
    error NotAdmin(address account_);
    
    /**
    * @dev 管理者アカウントを追加できなかった場合に発生するエラー
    * @param account_ 管理者に追加しようとしたが失敗したアカウント
    */
    error DoNotAddAdmin(address account_);

    /**
    * @dev 管理者アカウントを削除できなかった場合に発生するエラー
    * @param account_ 管理者から削除しようとしたが失敗したアカウント
    */
    error DoNotRemoveAdmin(address account_);
}
