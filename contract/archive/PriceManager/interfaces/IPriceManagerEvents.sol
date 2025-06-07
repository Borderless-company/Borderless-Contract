// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IPriceManagerEvents {
    /**
     * @notice Emitted when the price is set
     * @param price The price of the SCR
     */
    event PriceSet(uint256 price);
}
