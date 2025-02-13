// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface ErrorLETSBase {
	/**
	 * @dev not mint reserve error
	 * @param caller caller address
	 */
	error NotMintReserve(address caller);

	/**
	 * @dev not governance error
	 * @param caller caller address
	 */
	error NotGovernance(address caller);

	/**
	 * @dev invalid parameter error
	 * @param _caller caller address
	 * @param _name token name
	 * @param _symbol token symbol
	 * @param _baseURI token baseURI
	 * @param _governanceService governance service address
	 */
	error InvalidParam(
		address _caller,
		string _name,
		string _symbol,
		string _baseURI,
		string _extension,
		address _governanceService
	);

	/**
	 * @dev not transferable error
	 */
	error NotTransferable();

	/**
	 * @dev not founder error
	 * @param caller caller address
	 */
	error NotFounder(address caller);
}
