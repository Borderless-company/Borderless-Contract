// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface EventLETSBase {
	/**
	 * @dev mint reserve set event
	 * @param tokenId token id
	 * @param to address to
	 */
	event MintReserveSet(uint256 tokenId, address to);

	/**
	 * @dev token frozen event
	 * @param tokenId token id
	 */
	event TokenFrozen(uint256 tokenId);

	/**
	 * @dev token unfrozen event
	 * @param tokenId token id
	 */
	event TokenUnfrozen(uint256 tokenId);
}
