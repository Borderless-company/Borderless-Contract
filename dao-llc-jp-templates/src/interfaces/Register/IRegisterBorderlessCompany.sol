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
}
