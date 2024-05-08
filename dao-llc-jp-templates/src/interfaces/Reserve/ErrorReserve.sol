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
    error AlreadyReserve(address account_);

    /**
    * @dev 既に予約契約なしアカウントが提供された場合に発生するエラー
    * @param account_ 予約契約がないアカウント
    */
    error NotyetReserve(address account_);

    /**
    * @dev ホワイトリストにアカウントを追加できなかった場合に発生するエラー
    * @param account_ ホワイトリストに追加しようとしたが失敗したアカウント
    */
    error DoNotToAddWhitelist(address account_);

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
    error DoNotSetAdmin(address account_);

    /**
    * @dev 管理者アカウントを削除できなかった場合に発生するエラー
    * @param account_ 管理者から削除しようとしたが失敗したアカウント
    */
    error DoNotDeleteAdmin(address account_);
}
