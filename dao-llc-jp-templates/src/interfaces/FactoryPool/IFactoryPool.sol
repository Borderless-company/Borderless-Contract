// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

interface IFactoryPool {
    struct ServiceInfo{
        address service;
        bool online;
        uint256 createAt;
        uint256 updateAt;
    }

    /**
    * @dev サービスアドレスを設定します。この関数はコントラクトオーナーのみが実行できます。
    * @param service_ 設定するサービスのアドレスです。
    */
    function setService(address service_) external;

    function getLatestIndex() external returns(uint256 index_);

    /**
    * @dev 指定されたインデックスのサービスアドレスとオンライン状態を取得します。
    * @param index_ サービスのインデックスです。
    * @return service_ サービスのアドレスです。
    * @return online_ サービスがオンラインであるかどうかを示すブール値です。
    */
    function getService(uint256 index_) external returns(address service_, bool online_);

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
    function updateService(address service_, uint256 index_, bool online_) external;
}
