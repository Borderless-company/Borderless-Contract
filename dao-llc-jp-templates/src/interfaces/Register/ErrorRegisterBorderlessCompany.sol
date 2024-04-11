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
    * @dev Borderless.companyを起動（設立）できなかった場合に発生するエラー
    * @param account_ 起動（設立）しようとしたが失敗したアカウント
    */
    error DoNotCreateBorderlessCompany(address account_);
}
