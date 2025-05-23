// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IPriceManagerFunctions {
    /**
     * @notice Set the price of the SCR
     * @param price The price of the SCR
     */
    function setPrice(uint256 price) external;

    /**
     * @notice Get the price of the SCR
     * @return The price of the SCR
     */
    function getPrice() external view returns (uint256);
}