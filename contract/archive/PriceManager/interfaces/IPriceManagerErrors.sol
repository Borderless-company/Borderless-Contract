// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IPriceManagerErrors {
    /**
     * @notice Emitted when the price is set
     */
    error PriceMustBeGreaterThanZero();
}
