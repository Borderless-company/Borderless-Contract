// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for SCT contract
interface ISCT {
	// ============================================== //
	//            External Write Functions            //
	// ============================================== //

	/**
	 * @dev Initialize the SCT
	 * @notice Only Register can execute this function.
	 * @param _founder Initial founder
	 * @param _services Initial service addresses
	 * @return completed_ Initialize completed
	 */
	function initialService(
		address _founder,
		address[] calldata _services
	) external returns (bool completed_);

	// ============================================== //
	//            External Read Functions             //
	// ============================================== //

	/**
	 * @dev 指定されたインデックスのサービスを取得します。
	 * @param index_ サービスのインデックスです。
	 * @return service_ 指定されたインデックスのサービスのアドレスです。
	 */
	function getService(uint256 index_) external returns (address service_);

	function getInvestmentAmount(
		address account_
	) external returns (uint256 investmentAmount_);
}
