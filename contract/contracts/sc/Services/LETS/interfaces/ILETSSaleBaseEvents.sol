// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSSaleBaseEvents {
    /**
     * @dev token purchase event
     * @param tokenId token id
     * @param to address to
     * @param price price
     */
    event TokenPurchased(uint256 tokenId, address to, uint256 price);
}
