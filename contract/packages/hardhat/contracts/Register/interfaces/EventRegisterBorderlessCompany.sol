// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Event interface for RegisterBorderlessCompany contract
interface EventRegisterBorderlessCompany {
    // Note: EventRegisterBorderlessCompany is an event interface
    /**
     * @dev 新しいBorderless.companyが作成されたことを通知するイベントです。
     * @param founder_ Borderless.companyを起動した呼び出し元のアドレスです。
     * @param company_ 新しく作成されたBorderless.companyのアドレスです。
     * @param companyIndex_ 新しく作成されたBorderless.companyのインデックスです。
     */
    event NewBorderlessCompany(
        address indexed founder_,
        address indexed company_,
        uint256 indexed companyIndex_
    );

    /**
     * @dev Registerコントラクトから使用されるファクトリープールのアドレスの設定が変更された際に発生するイベントです。
     * @param account_ ファクトリープールの設定を変更したアカウントのアドレス
     * @param pool_ 設定された新しいファクトリープールのアドレス
     */
    event SetFactoryPool(address indexed account_, address indexed pool_);

    /**
     * @dev コントラクト管理者が追加されたときに発生するイベント
     * @param account_ 新しく追加された管理者アカウントのアドレス
     * @param count_ 新しく追加された管理者アカウントのカウント数
     */
    event NewAdmin(address indexed account_, uint256 indexed count_);

    /**
     * @dev コントラクト管理者が削除されたときに発生するイベント
     * @param account_ 削除された管理者アカウントのアドレス
     * @param count_ 削除された管理者アカウントのカウント数
     */
    event RemoveAdmin(address indexed account_, uint256 indexed count_);
}
