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
    * @dev 指定されたアカウントがホワイトリストに含まれているかを確認する外部公開関数
    * @notice オーナー以外もこの関数を呼び出せます
    * @param account_ 確認するアカウントのアドレス
    * @return listed_ アカウントがリストに含まれているかどうかのブール値
    */
    function isWhitelisted(address account_) external returns(bool listed_);
}
