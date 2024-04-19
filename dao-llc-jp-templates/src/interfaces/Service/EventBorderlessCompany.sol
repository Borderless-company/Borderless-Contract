// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Event interface for BorderlessCompny contract
interface EventBorderlessCompany {
    /**
    * @dev サービスの初期設定が完了したことを通知するイベントです。
    * @param company_ サービスの初期設定を行った企業のアドレスです。
    * @param governance_ サービスの初期設定に関連するガバナンスのアドレスです。
    * @param treasury_ サービスの初期設定に関連するトレジャリーのアドレスです。
    * @param token_ サービスの初期設定に関連するトークンのアドレスです。
    */
    event InitialService(address indexed company_, address governance_, address treasury_, address token_);

    /**
    * @dev サービスが追加されたことを通知するイベントです。
    * @param service_ 追加されたサービスのアドレスです。
    * @param index_ 追加されたサービスのインデックスです。
    */
    event AddService(address indexed service_, uint256 indexed index_);

    /**
    * @dev サービスが削除されたことを通知するイベントです。
    * @param service_ 削除されたサービスのアドレスです。
    * @param index_ 削除されたサービスのインデックスです。
    */
    event RemoveService(address indexed service_, uint256 indexed index_);

    /**
    * @dev 管理者の役割が割り当てられたことを通知するイベントです。
    * @param admin_ 役割が割り当てられた管理者のアドレスです。
    */
    event AssignmentRoleAdmin(address indexed admin_);

    /**
    * @dev メンバーの役割が割り当てられたことを通知するイベントです。
    * @param member_ 役割が割り当てられたメンバーのアドレスです。
    */
    event AssignmentRoleMember(address indexed member_);

    /**
    * @dev 管理者の役割が解除されたことを通知するイベントです。
    * @param admin_ 役割が解除された管理者のアドレスです。
    */
    event ReleaseRoleAdmin(address indexed admin_);

    /**
    * @dev メンバーの役割が解除されたことを通知するイベントです。
    * @param member_ 役割が解除されたメンバーのアドレスです。
    */
    event ReleaseRoleMember(address indexed member_);
}
