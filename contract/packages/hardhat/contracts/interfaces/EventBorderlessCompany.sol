// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Event interface for BorderlessCompny contract
interface EventBorderlessCompany {
    /**
     * @dev サービスの初期設定が完了したことを通知するイベントです。
     * @param company_ サービスの初期設定を行った企業のアドレスです。
     * @param governance_ サービスの初期設定に関連するガバナンスのアドレスです。
     * @param treasury_ サービスの初期設定に関連するトレジャリーのアドレスです。
     * @param token_ サービスの初期設定に関連するトークンのアドレスです。
     */
    event InitialService(
        address indexed company_,
        address governance_,
        address treasury_,
        address token_
    );

    /**
     * @dev 管理者の役割が割り当てられたことを通知するイベントです。
     * @param admin_ 役割が割り当てられた管理者のアドレスです。
     * @param assigned_ 役割が割り当て完了を示すブールです。
     */
    event AssignmentRoleAdmin(address indexed admin_, bool assigned_);

    /**
     * @dev メンバーの役割が割り当てられたことを通知するイベントです。
     * @param member_ 役割が割り当てられたメンバーのアドレスです。
     * @param assigned_ 役割が割り当て完了を示すブールです。
     */
    event AssignmentRoleMember(address indexed member_, bool assigned_);

    /**
     * @dev 管理者の役割が解除されたことを通知するイベントです。
     * @param admin_ 役割が解除された管理者のアドレスです。
     * @param released_ 役割が割り当て解除を示すブールです。
     */
    event ReleaseRoleAdmin(address indexed admin_, bool released_);

    /**
     * @dev メンバーの役割が解除されたことを通知するイベントです。
     * @param member_ 役割が解除されたメンバーのアドレスです。
     * @param released_ 役割が割り当て解除を示すブールです。
     */
    event ReleaseRoleMember(address indexed member_, bool released_);
}
