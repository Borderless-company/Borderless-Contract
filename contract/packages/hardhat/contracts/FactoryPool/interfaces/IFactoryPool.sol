// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface IFactoryPool {
    struct ServiceInfo {
        address service;
        bool online;
        uint256 createAt;
        uint256 updateAt;
    }

    /**
     * @dev サービスアドレスを設定します。この関数はコントラクトオーナーのみが実行できます。
     * @param service_ 設定するサービスのアドレスです。
     * @param index_ 設定するサービスのIndex値です。
     */
    function setService(address service_, uint256 index_) external;

    /**
     * @dev 指定されたインデックスのサービスアドレスとオンライン状態を取得します。
     * @param index_ サービスのインデックスです。
     * @return service_ サービスのアドレスです。
     * @return online_ サービスがオンラインであるかどうかを示すブール値です。
     */
    function getService(
        uint256 index_
    ) external returns (address service_, bool online_);

    /**
     * @dev 指定されたインデックスのサービスアドレスを更新します。この関数はコントラクトオーナーのみが実行できます。
     * @param service_ 更新後のサービスのアドレスです。
     * @param index_ 更新するサービスのインデックスです。
     */
    function updateService(address service_, uint256 index_) external;

    /**
     * @dev 指定されたインデックスのサービスアドレスとオンライン状態を更新します。この関数はコントラクトオーナーのみが実行できます。
     * @param service_ 更新後のサービスのアドレスです。
     * @param index_ 更新するサービスのインデックスです。
     * @param online_ サービスのオンライン状態を示すブール値です。
     */
    function updateService(
        address service_,
        uint256 index_,
        bool online_
    ) external;

    /**
     * @dev 新しい管理者を追加する関数です。
     * @param account_ 追加する新しい管理者のアドレスです。
     * @return assigned_ 管理者が正常に追加された場合はtrueを返します。
     */
    function addAdmin(address account_) external returns (bool assigned_);

    /**
     * @dev 管理者を削除する関数です。
     * @param account_ 削除する管理者のアドレスです。
     * @return assigned_ 管理者が正常に削除された場合はtrueを返します。
     */
    function removeAdmin(address account_) external returns (bool assigned_);

    /**
     * @dev 指定されたアカウントが管理者であるかどうかを確認する関数です。
     * @param account_ 確認したいアカウントのアドレスです。
     * @return assigned_ 指定されたアカウントが管理者である場合はtrueを返します。
     */
    function isAdmin(address account_) external returns (bool assigned_);
}
