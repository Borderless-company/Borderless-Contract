// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSBaseEvents {
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
