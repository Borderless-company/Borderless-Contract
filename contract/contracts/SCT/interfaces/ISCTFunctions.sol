// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../utils/ITypes.sol";

/**
 * @title ISCT Functions v0.1.0
 */
interface ISCTFunctions {
	// ============================================== //
	//            External Write Functions            //
	// ============================================== //

	/**
	 * @dev Register Service Contract
	 * @notice Only Register Contract can execute this function.
	 * @param serviceTypes Initial service types
	 * @param services Initial service addresses
	 * @return completed Initialize completed
	 */
	function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) external returns (bool completed);

	/**
	 * @dev Set the investment amount
	 * @param account The account address
	 * @param investmentAmount The investment amount
	 */
	function setInvestmentAmount(
		address account, uint256 investmentAmount) external;

	// ============================================== //
	//            External Read Functions             //
	// ============================================== //

	/**
	 * @dev Get the SCR address
	 * @return scr The address of the SCR
	 */
	function getSCR() external view returns (address scr);

	/**
	 * @dev Get the service at the specified index
	 * @param serviceType The type of the service
	 * @return service The address of the service
	 */
	function getService(ServiceType serviceType) external returns (address service);

	/**
	 * @dev Get the investment amount
	 * @param account The account address
	 * @return investmentAmount The investment amount
	 */
	function getInvestmentAmount(
		address account
	) external returns (uint256 investmentAmount);
}
