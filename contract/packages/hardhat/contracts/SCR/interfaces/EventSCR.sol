// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Event interface for SCR contract
interface EventSCR {
	// Note: EventSCR is an event interface
	/**
	 * @dev 新しいSmartCompanyが作成されたことを通知するイベントです。
	 * @param founder_ SmartCompanyを起動した呼び出し元のアドレスです。
	 * @param company_ 新しく作成されたSmartCompanyのアドレスです。
	 * @param companyIndex_ 新しく作成されたBorderless.companyのインデックスです。
	 */
	event NewSmartCompany(
		address indexed founder_,
		address indexed company_,
		uint256 indexed companyIndex_
	);

	/**
	 * @dev Registerコントラクトから使用されるファクトリープールのアドレスの設定が変更された際に発生するイベントです。
	 * @param account_ ファクトリープールの設定を変更したアカウントのアドレス
	 * @param pool_ 設定された新しいファクトリープールのアドレス
	 */
	event SetFactoryPool(address indexed account_, address indexed pool_);

	/**
	 * @dev SmartCompanyコントラクトをデプロイした時に、セットでデプロイされるSmartCompanyの数を設定した際に発生するイベントです。
	 * @param account_ ServiceCountを設定したアカウントのアドレス
	 * @param count_ 設定された新しいSmartCompanyの数
	 */
	event SetCompanyServiceCount(
		address indexed account_,
		uint256 indexed count_
	);

	event UpdateCompanyInfoField(
		address indexed account,
		uint256 indexed fieldIndex,
		string legalEntityCode,
		string field
	);

	event DeleteCompanyInfoField(
		address indexed account,
		uint256 indexed fieldIndex,
		string legalEntityCode
	);
}
