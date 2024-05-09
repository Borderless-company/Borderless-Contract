// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Event interface for Reserve contract
interface EventReserve { // Note: EventReserve is an Event interface
    /**
    * @dev 新しい予約者が追加されたときに発生するイベント
    * @param account_ 新しく予約契約されたアカウントのアドレス
    * @param index_ 新しく予約契約されたインデックス値
    */
    event NewReserver(address indexed account_, uint256 indexed index_);

    /**
    * @dev 予約契約がキャンセルされたときに発生するイベント
    * @param account_ 新しく予約契約されたアカウントのアドレス
    * @param index_ 新しく予約契約されたインデックス値
    */
    event CancelReserve(address indexed account_, uint256 indexed index_);

    /**
    * @dev コントラクト管理者が追加されたときに発生するイベント
    * @param account_ 新しく追加された管理者アカウントのアドレス
    */
    event NewAdmin(address indexed account_);

    /**
    * @dev コントラクト管理者が削除されたときに発生するイベント
    * @param account_ 削除された管理者アカウントのアドレス
    */
    event RemoveAdmin(address indexed account_);
}
