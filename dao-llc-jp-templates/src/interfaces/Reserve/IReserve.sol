// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title feature interface for Whitelist contract
interface IReserve { // Note: IWhitelist is an feature interface
    /**
    * @dev ホワイトリストにアカウントを追加する外部公開関数
    * @notice オーナーのみがこの関数を呼び出せます
    * - onlyOwner モディファイアを使用して、オーナーのみがこの関数を呼び出せるようにします
    * @param account_ 追加するアカウントのアドレス
    * @return listed_ アカウントがリストに追加されたかどうかのブール値
    */
    function reservation(address account_) external returns(bool listed_);

    /**
    * @dev 指定されたアカウントをホワイトリストから解除する関数
    * @notice オーナーのみがこの関数を呼び出せます
    * @param account_ 予約解除するアカウントのアドレス
    * @return listed_ アカウントがリストに含まれているかどうかのブール値
    */
    function cancel(address account_) external returns(bool listed_);

    /**
    * @dev 新しい管理者を設定するための関数です。
    * @param account_ 新しい管理者のアドレスです。
    * @return assigned_ 管理者が正常に設定された場合はtrueを返します。
    */
    function setAdmin(address account_) external returns(bool assigned_);

    /**
    * @dev 指定されたアカウントがホワイトリストに含まれているかを確認する外部公開関数
    * @notice オーナー以外もこの関数を呼び出せます
    * @param account_ 確認するアカウントのアドレス
    * @return listed_ アカウントがリストに含まれているかどうかのブール値
    */
    function isWhitelisted(address account_) external returns(bool listed_);

    /**
    * @dev 予約者数のインデックスを取得するための関数
    * @return index_ 予約者のインデックスです。
    */
    function lastIndexOf() external returns(uint256 index_);

    /**
    * @dev 予約者のアドレスを取得するための関数
    * @notice オーナーのみがこの関数を呼び出せます
    * @return reserver_ 予約者のアドレスです。
    */
    function reserverOf(uint256 index_) external view returns(address reserver_);

    /**
    * @dev 全予約者のアドレスを取得するための関数です。
    * @notice オーナーのみがこの関数を呼び出せます
    * @return reservers_ 予約者のアドレスの配列です。
    */
    function reserversOf() external view returns(address[] memory reservers_);
}
