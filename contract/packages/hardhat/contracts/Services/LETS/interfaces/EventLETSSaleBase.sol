// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface EventLETSSaleBase {
    /**
     * @dev token purchase event
     * @param tokenId token id
     * @param to address to
     * @param price price
     */
    event TokenPurchased(uint256 tokenId, address to, uint256 price);
}
