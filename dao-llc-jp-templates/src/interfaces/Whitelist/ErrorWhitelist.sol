// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Error interface for Whitelist contract
interface ErrorWhitelist { // Note: ErrorWhitelist is an Error interface
    /**
    * @dev 無効なアドレスが提供された場合に発生するエラー
    * @param account_ 無効なアドレスとして提供されたアカウント
    */
    error InvalidAddress(address account_);

    /**
    * @dev 既に予約済みのアカウントが提供された場合に発生するエラー
    * @param account_ 既に予約されたアカウント
    */
    error ReserverAlready(address account_);

    /**
    * @dev ホワイトリストにアカウントを追加できなかった場合に発生するエラー
    * @param account_ ホワイトリストに追加しようとしたが失敗したアカウント
    */
    error DoNotToAddWhitelist(address account_);
}
