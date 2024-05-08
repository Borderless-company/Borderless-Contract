// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Error interface for RegisterBorderlessCompany contract
interface ErrorRegisterBorderlessCompany { // Note: ErrorRegisterBorderlessCompany is an event interface
    /**
    * @dev 不正な事業リソースが提供された場合に発生するエラー
    * @param account_ 起動（設立）しようとしたが失敗したアカウント
    */
    error InvalidCompanyInfo(address account_);

    /**
    * @dev 無効なアドレスが提供された場合に発生するエラー
    * @param account_ 無効なアドレスとして提供されたアカウント
    */
    error InvalidAddress(address account_);

    /**
    * @dev 不正なアドレスリソースが提供された場合に発生するエラー
    * @param account_ 不正なアドレス（アカウント）
    */
    error InvalidParam(address account_);

    /**
    * @dev Borderless.companyを起動（設立）できなかった場合に発生するエラー
    * @param account_ 起動（設立）しようとしたが失敗したアカウント
    */
    error DoNotCreateBorderlessCompany(address account_);

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
    error DoNotRemoveAdmin(address account_);
}
