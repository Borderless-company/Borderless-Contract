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
   * @dev サービスが設定されていない場合に発生するエラーです。
   * @param service_ エラーが発生したサービスのアドレスです。
   */
   error DoNotSetService(address service_);
}
