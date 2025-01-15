// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface ErrorSCT {
	/**
	 * @dev アカウントが無効であることを通知するエラーです。
	 * @param account_ エラーが発生したアカウントのアドレスです。
	 */
	error InvalidAddress(address account_);

	/**
	 * @dev 登録者が無効であることを通知するエラーです。
	 * @param account_ エラーが発生したアカウントのアドレスです。
	 */
	error InvalidRegister(address account_);

	/**
	 * @dev 初期設定が完了していることを通知するエラーです。
	 */
	error InitialServiceCompleted();

	/**
	 * @dev 初期設定が完了していることを通知するエラーです。
	 */
	error InitialRoleCompleted();

	/**
	 * @dev Not governance contract Error。
	 * @param account_ function caller
	 */
	error NotGovernanceContract(address account_);

	/**
	 * @dev インデックスが無効であることを通知するエラーです。
	 * @param index_ エラーが発生したインデックスです。
	 */
	error InvalidIndex(uint256 index_);

	// -- 3. 初期設定済み機能の不正設定リバート -- //
	/**
	 * @dev 初期設定済みの機能がすでに設定されていることを通知するエラーです。
	 * @param account_ エラーが発生したアカウントのアドレスです。
	 */
	error AlreadyInitialService(address account_);
}
