// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Event interface for Reserve contract
interface EventReserve { // Note: EventReserve is an Event interface
    /**
    * @dev 新しい予約者が追加されたときに発生するイベント
    * @param caller_ イベントを発生させた呼び出し元のアドレス
    * @param account_ 新しく予約されたアカウントのアドレス
    */
    event NewReserver(address indexed caller_, address indexed account_);

    /**
    * @dev 予約契約がキャンセルされたときに発生するイベント
    * @param caller_ イベントを発生させた呼び出し元のアドレス
    * @param account_ 予約キャンセルしたアカウントのアドレス
    */
    event CancelReserve(address indexed caller_, address indexed account_);
}
