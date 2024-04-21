// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Error interface for Reserve contract
interface ErrorReserve { // Note: ErrorReserve is an Error interface
    /**
    * @dev 無効なアドレスが提供された場合に発生するエラー
    * @param account_ 無効なアドレスとして提供されたアカウント
    */
    error InvalidAddress(address account_);

    /**
    * @dev 不正なインデックスが提供された場合に発生するエラー
    * @param index_ 無効な値として提供されたインデックス値
    */
    error InvalidIndex(uint256 index_);

    /**
    * @dev 既に予約済みのアカウントが提供された場合に発生するエラー
    * @param account_ 既に予約されたアカウント
    */
    error AlreadyReserver(address account_);

    /**
    * @dev 既に予約契約なしアカウントが提供された場合に発生するエラー
    * @param account_ 予約契約がないアカウント
    */
    error AlreadyNotReserve(address account_);

    /**
    * @dev ホワイトリストにアカウントを追加できなかった場合に発生するエラー
    * @param account_ ホワイトリストに追加しようとしたが失敗したアカウント
    */
    error DoNotToAddWhitelist(address account_);
}
