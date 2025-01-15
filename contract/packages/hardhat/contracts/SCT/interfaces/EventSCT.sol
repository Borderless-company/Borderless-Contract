// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Event interface for BorderlessCompny contract
interface EventSCT {
	/**
	 * @dev サービスの初期設定が完了したことを通知するイベントです。
	 * @param company_ サービスの初期設定を行ったCompanyのアドレスです。
	 * @param services_ サービスの初期設定に関連するサービスのアドレスです。
	 */
	event InitialService(address indexed company_, address[] services_);
}
