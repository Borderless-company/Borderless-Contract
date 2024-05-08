// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title feature interface for RegisterBorderlessCompany contract
interface IRegisterBorderlessCompany { // Note: IRegisterBorderlessCompany is an feature interface
    struct CompanyInfo {
        address companyAddress;
        address founder;
        bytes companyID;
        bytes establishmentDate;
        bool confirmed;
        uint256 createAt;
        uint256 updateAt;
    }

    /**
    * @dev ボーダーレス企業を作成します。
    * @param companyID_ 企業のIDです。
    * @param establishmentDate_ 企業の設立日時です。
    * @param confirmed_ 企業が確認されているかどうかです。
    * @return started_ 企業作成が開始されたかどうかを示すブール値です。
    * @return companyAddress_ 作成された企業コントラクトを示すアドレス値です。
    */
    function createBorderlessCompany(bytes calldata companyID_, bytes calldata establishmentDate_, bool confirmed_) external returns(bool started_, address companyAddress_);

    /**
    * @dev Registerコントラクトから使用されるファクトリープールのアドレスを設定します。
    * @param factoryPool_ 設定するファクトリープールのアドレス
    */
    function setFactoryPool(address factoryPool_) external;

    /**
    * @dev 新しい管理者を追加する関数です。
    * @param account_ 追加する新しい管理者のアドレスです。
    * @return assigned_ 管理者が正常に追加された場合はtrueを返します。
    */
    function addAdmin(address account_) external returns(bool assigned_);

    /**
    * @dev 管理者を削除する関数です。
    * @param account_ 削除する管理者のアドレスです。
    * @return assigned_ 管理者が正常に削除された場合はtrueを返します。
    */
    function removeAdmin(address account_) external returns(bool assigned_);

    /**
    * @dev 指定されたアカウントが管理者であるかどうかを確認する関数です。
    * @param account_ 確認したいアカウントのアドレスです。
    * @return assigned_ 指定されたアカウントが管理者である場合はtrueを返します。
    */
    function isAdmin(address account_) external returns(bool assigned_);
}
