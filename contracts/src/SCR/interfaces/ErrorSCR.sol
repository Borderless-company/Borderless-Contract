// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Error interface for SCR contract
interface ErrorSCR {
	// Note: ErrorSCR is an event interface

	/**
	 * @dev 不正な事業リソースが提供された場合に発生するエラー
	 * @param account 起動（設立）しようとしたが失敗したアカウント
	 */
	error InvalidCompanyInfo(address account);

	/**
	 * @dev otherInfoの数が不正な場合に発生するエラー
	 * @param account 起動（設立）しようとしたが失敗したアカウント
	 */
	error InvalidOtherInfo(address account);

	/**
	 * @dev 不正なアドレスリソースが提供された場合に発生するエラー
	 */
	error InvalidParam();

	/**
	 * @dev 不正な起動（設立）者が提供された場合に発生するエラー
	 * @param founder 起動（設立）者のアドレス
	 */
	error InvalidFounder(address founder);

	/**
	 * @dev SmartCompanyを起動（設立）できなかった場合に発生するエラー
	 * @param account 起動（設立）しようとしたが失敗したアカウント
	 */
	error DoNotCreateSmartCompany(address account);

	/**
	 * @dev 既に起動（設立）済みのSmartCompanyが提供された場合に発生するエラー
	 * @param account 起動（設立）済みのSmartCompanyのアカウント
	 */
	error AlreadyEstablish(address account);

	/**
	 * @dev 既に起動（設立）済みのSmartCompanyが提供された場合に発生するエラー
	 * @param account 起動（設立）済みのSmartCompanyのアカウント
	 * @param scsAddress 起動（設立）済みのSmartCompanyのアドレス
	 * @param scsType 起動（設立）済みのSmartCompanyのタイプ
	 */
	error AlreadyDeployedService(
		address account,
		address scsAddress,
		uint256 scsType
	);

	/**
	 * @dev サービスがオンラインでない場合に発生するエラー
	 * @param account サービスを起動（設立）しようとしたアカウント
	 * @param scsAddress サービスのアドレス
	 */
	error ServiceNotOnline(address account, address scsAddress);
}
