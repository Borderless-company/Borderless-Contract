// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title feature interface for BorderlessCompny contract
interface IBorderlessCompany { // Note: IBorderlessCompny is an feature interface
    /**
    * @dev サービスの初期設定を行います。
    * @notice Registerからのみ実行できます。
    * - onlyRegister モディファイアを使用して、オーナーのみがこの関数を呼び出せるようにします。
    * @param services_ 初期設定するサービスのアドレス配列です。
    * @return completed_ 初期設定するサービスのアドレスが設定されたかどうかのブール値です。
    */
    function initialService(address[] memory services_) external returns(bool completed_);

    /**
    * @dev 指定されたインデックスのサービスを取得します。
    * @param index_ サービスのインデックスです。
    * @return service_ 指定されたインデックスのサービスのアドレスです。
    */
    function getService(uint256 index_) external returns(address service_);

    /**
    * @dev アカウントに役割を割り当てます。
    * @param account_ 役割を割り当てるアカウントのアドレスです。
    * @param isAdmin_ 管理者権限を割り当てるかどうかを示すブール値です。
    * @return assigned_ 役割の割り当てが完了したかを示すブール値です。
    */
    function assignmentRole(address account_, bool isAdmin_) external returns(bool assigned_);

    /**
    * @dev アカウントの役割を解除します。
    * @param account_ 役割を解除するアカウントのアドレスです。
    * @param isAdmin_ 管理者権限を解除するかどうかを示すブール値です。
    * @return released_ 役割の解除が完了したかを示すブール値です。
    */
    function releaseRole(address account_, bool isAdmin_) external returns(bool released_);
}
